class GameCard < ApplicationRecord
  belongs_to :game
  belongs_to :card
  belongs_to :game_player, optional: true
  enum :place, {
    supply: 0,
    draw_pile: 1,
    hand: 2,
    in_play: 3,
    discard_pile: 4,
    trash: 5
  }
  def self.setup_supplies!(game: )
    transaction do
      [
        { name: "銅貨", supply_number: 46 },
        { name: "銀貨", supply_number: 40 },
        { name: "金貨", supply_number: 30 },
        { name: "屋敷", supply_number: 8 },
        { name: "公領", supply_number: 8 },
        { name: "属州", supply_number: 8 },
      ].flat_map do |attrs|
        card = Card.find_by!(name: attrs[:name])
        attrs[:supply_number].times.map do |position|
          GameCard.create!(
            game: game,
            card: card,
            place: :supply,
            position: position
          )
        end
      end
    end
  end
  def self.first_deal!(game_player: )
    transaction do
      game_cards = [
        { name: "銅貨", number: 7 },
        { name: "屋敷", number: 3 },
      ].flat_map do |attr|
        game_player.game.game_cards.supply.joins(:card).where(cards: {name: attr[:name]}, place: :supply).limit(attr[:number])
      end
      positions = (0...game_cards.count).to_a.shuffle
      game_cards.zip(positions).each do |game_card, position|
        game_card.update!(place: :draw_pile,  game_player: game_player, position: position)
      end
    end
  end
end
