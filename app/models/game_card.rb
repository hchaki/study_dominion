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
end
