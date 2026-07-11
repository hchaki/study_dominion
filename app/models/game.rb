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
  def self.setup!(player:)
    transaction do
      game = create!(
        status: :playing,
        turn_phase: :action,
        actions_remaining: 1,
        buys_remaining: 1,
        coins: 0,
      )
      game_player = game.game_players.create!(player: player, seat_order: 0)
      game.setup_supplies!
      game_player.first_deal!
      game_player.draw!(5)
      game.turns.create!(number: 1, game_player: game_player)
      game
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

  def play_until_end!
    until game_over?
      game_players.first.take_turn!
    end
  end

  def game_over?
    game_cards.supply.joins(:card).where(cards: { name: "属州"}).count == 0
  end
end
