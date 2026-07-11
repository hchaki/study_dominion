class CardKind < ApplicationRecord
  belongs_to :card
  enum :kind, {
    treasure: 0,
    victory: 1,
    action: 2,
    curse: 3
  }
end
