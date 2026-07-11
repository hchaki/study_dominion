class TurnAction < ApplicationRecord
  belongs_to :turn
  belongs_to :game_card
  enum :action, {
    draw: 0,
    play: 1,
    buy: 2,
    discard: 3,
    trash: 4
  }
end
