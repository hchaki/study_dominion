class Card < ApplicationRecord
  has_many :card_kinds
  TREASURE_COINS = { "銅貨" => 1, "銀貨" => 2, "金貨" => 3 }.freeze
  VICTORY_POINTS = { "屋敷" => 1, "公領" => 3, "属州" => 6 }.freeze
end
