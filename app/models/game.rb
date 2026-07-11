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
      game_player =game.game_players.create!(player: player, seat_order: 0)
      GameCard.setup_supplies!(game: game)
      GameCard.first_deal!(game_player: game_player )
      game_player.draw!(5)
      game.turns.create!(number: 1, game_player: game_player)
      game
    end
  end
end
