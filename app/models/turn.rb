class Turn < ApplicationRecord
  has_many :turn_actions
  belongs_to :game
  belongs_to :game_player
end
