class Card < ApplicationRecord
  has_many :card_kinds
  TREASURE_COINS = { "銅貨" => 1, "銀貨" => 2, "金貨" => 3 }.freeze
end
