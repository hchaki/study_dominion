class Game < ApplicationRecord
  has_many :game_players
  has_many :game_cards
  has_many :turns
  enum :status, {
    waiting: 0,
    playing: 1,
    finish: 2
  }
  enum :turn_phase, {
    action: 0,
    buy: 1,
    cleanup: 2
  }
  def self.setup!(participants:)
    # participants: [{ player:, cpu: }, ...] の配列(座席順)
    transaction do
      game = create!(
        status: :playing,
        turn_phase: :action,
        actions_remaining: 1,
        buys_remaining: 1,
        coins: 0,
      )
      game.setup_supplies!
      seated = participants.each_with_index.map do |part, i|
        game_player = game.game_players.create!(player: part[:player], seat_order: i, cpu: part[:cpu])
        game_player.first_deal!
        game_player.draw!(5)
        game_player
      end
      game.turns.create!(number: 1, game_player: seated.first)
      game
    end
  end

  # 今の手番プレイヤー = 最新の turn の game_player(turns が手番の正データ)
  def current_game_player
    turns.order(:number).last.game_player
  end

  # 次の手番プレイヤー(seat_order を1つ進め、一周したら先頭に戻る)
  def next_game_player
    order = (current_game_player.seat_order + 1) % game_players.count
    game_players.find_by(seat_order: order)
  end

  # 手番を終える: 今のプレイヤーが後片付け → 次のプレイヤーの turn を作る
  def end_turn!
    transaction do
      current_game_player.cleanup!
      turns.create!(number: turns.count + 1, game_player: next_game_player)
    end
  end

  def setup_supplies!
    transaction do
      [
        { name: "銅貨", supply_number: 46 },
        { name: "銀貨", supply_number: 40 },
        { name: "金貨", supply_number: 30 },
        { name: "屋敷", supply_number: 8 },
        { name: "公領", supply_number: 8 },
        { name: "属州", supply_number: 8 },
        { name: "村",     supply_number: 10 },
        { name: "鍛冶屋", supply_number: 10 },
        { name: "市場",   supply_number: 10 },
        { name: "研究所", supply_number: 10 },
        { name: "木こり", supply_number: 10 },
        { name: "祝祭",   supply_number: 10 },
        { name: "堀",     supply_number: 10 },
        { name: "地下貯蔵庫", supply_number: 10 },
        { name: "議事堂", supply_number: 10 },
        { name: "礼拝堂", supply_number: 10 },
      ].flat_map do |attrs|
        card = Card.find_by!(name: attrs[:name])
        attrs[:supply_number].times.map do |i|
          game_cards.create!(
            card: card,
            place: :supply,
            position: i
          )
        end
      end
    end
  end

  # 現在の手番が CPU の間、自動でプレイして手番を進める(人間の番に戻るまで)
  def play_cpu_turns!
    while !game_over? && current_game_player.cpu?
      current_game_player.take_turn!
      end_turn!
    end
  end

  def play_until_end!
    until game_over?
      current_game_player.take_turn!
      end_turn!
    end
  end

  def game_over?
    game_cards.supply.joins(:card).where(cards: { name: "属州"}).count == 0
  end
end
