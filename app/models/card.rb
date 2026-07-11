class Card < ApplicationRecord
  has_many :card_kinds
  TREASURE_COINS = { "銅貨" => 1, "銀貨" => 2, "金貨" => 3 }.freeze
  VICTORY_POINTS = { "屋敷" => 1, "公領" => 3, "属州" => 6 }.freeze
  ACTION_EFFECTS = {
    "村"     => { cards: 1, actions: 2, buys: 0, coins: 0 },
    "鍛冶屋" => { cards: 3, actions: 0, buys: 0, coins: 0 },
    "市場"   => { cards: 1, actions: 1, buys: 1, coins: 1 },
    "研究所" => { cards: 2, actions: 1, buys: 0, coins: 0 },
    "木こり" => { cards: 0, actions: 0, buys: 1, coins: 2 },
    "祝祭"   => { cards: 0, actions: 2, buys: 1, coins: 2 },
    "堀"     => { cards: 2, actions: 0, buys: 0, coins: 0 },
    "地下貯蔵庫" => { cards: 0, actions: 1, buys: 0, coins: 0 },
  }.freeze
end
