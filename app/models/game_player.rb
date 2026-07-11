class GamePlayer < ApplicationRecord
  has_many :game_cards
  has_many :turns
  belongs_to :game
  belongs_to :player

  def first_deal!
    transaction do
      cards = [
        { name: "銅貨", number: 7 },
        { name: "屋敷", number: 3 },
      ].flat_map do |attr|
        game.game_cards.supply.joins(:card).where(cards: {name: attr[:name]}).limit(attr[:number])
      end
      positions = (0...cards.count).to_a.shuffle
      cards.zip(positions).each do |c, i|
        c.update!(place: :draw_pile,  game_player: self, position: i)
      end
    end
  end

  def draw!(n)
    transaction do
      remnant = game_cards.draw_pile.order(:position).to_a
      # 残り山札を上(0..)に、その下にシャッフルした捨て札を置く
      if remnant.length < n
        remnant.each.with_index(0) {|c, i| c.update!(position: i)}
        reshuffle!(offset: remnant.length)
      end
      start = game_cards.hand.length
      drawn = game_cards.draw_pile.order(:position).limit(n)

      drawn.each.with_index(start) { |c, i| c.update!(place: :hand, position: i)}
      drawn
    end
  end

  def play_action!(game_card, discard: [])
    transaction do
      raise "アクションフェイズではありません" unless game.action?
      game_card.update!(place: :in_play, position: game_cards.in_play.count)
      effects = Card::ACTION_EFFECTS[game_card.card.name]
      game.update!(
        actions_remaining: game.actions_remaining + effects[:actions] - 1,
        buys_remaining: game.buys_remaining + effects[:buys],
        coins: game.coins + effects[:coins]
      )
      draw!(effects[:cards]) if effects[:cards] >= 1

      # 手続き効果(地下貯蔵庫: 渡されたカードを捨て、同じ枚数引く)
      if game_card.card.name == "地下貯蔵庫"
        # discard の各カードを discard_pile へ移し、そのあと draw!(discard.size)
        discard.each do |c|
          c.update!(place: :discard_pile, position: game_cards.discard_pile.count)
        end
        draw!(discard.size)
      end
    end
  end

  def play_treasure!(game_card)
    transaction do
      value = Card::TREASURE_COINS[game_card.card.name]
      game.update!(coins: game.coins + value)
      game_card.update!(place: :in_play, position: game_cards.in_play.count)
    end
  end

  def play_all_treasures!
    transaction do
      game.update!(turn_phase: :buy)
      game_cards.hand.joins(card: :card_kinds).where(card_kinds: { kind: :treasure}).each do |c|
        play_treasure!(c)
      end
    end
  end

  def buy!(card)
    transaction do
      raise "購入金不足" if game.coins < card.cost
      raise "購入可能数なし" if game.buys_remaining < 1

      buying = game.game_cards.supply.where(card: card).order(:position).first
      raise "在庫なし" if buying.nil?

      buying.update!(place: :discard_pile, game_player: self, position: game_cards.discard_pile.count)
      game.update!(coins: game.coins - card.cost, buys_remaining: game.buys_remaining - 1, turn_phase: :buy)

    end
  end

  def cleanup!
    transaction do
      game_cards.in_play.update_all(place: :discard_pile)
      game_cards.hand.update_all(place: :discard_pile)
      draw!(5)
      game.update!(
        actions_remaining: 1,
        buys_remaining: 1,
        coins: 0,
        turn_phase: :action
      )
    end
  end

  def take_turn!
    transaction do
      play_all_treasures!
      card = card_to_buy       # ← 何を買うか決める(下で実装)
      buy!(card) if card
      cleanup!
    end
  end

  def card_to_buy
    return Card.find_by(name: "属州") if game.coins >= 8
    return Card.find_by(name: "金貨") if game.coins >= 6
    return Card.find_by(name: "銀貨") if game.coins >= 3
    return nil
  end

  def victory_points
    counts = game_cards.joins(:card).group("cards.name").count
    total = 0
    Card::VICTORY_POINTS.each do |name, points|
      total += (counts[name] || 0) * points
    end
    total
  end

  private def reshuffle!(offset: 0)
    discard = game_cards.discard_pile.to_a
    positions = (0...discard.length).to_a.shuffle
    discard.zip(positions).each do |c, p|
      c.update!(place: :draw_pile, position: p + offset)
    end
  end
end
