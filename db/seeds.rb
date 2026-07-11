# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  { name: "銅貨", cost: 0, kind: :treasure },
  { name: "銀貨", cost: 3, kind: :treasure },
  { name: "金貨", cost: 6, kind: :treasure },
  { name: "屋敷", cost: 2, kind: :victory },
  { name: "公領", cost: 5, kind: :victory },
  { name: "属州", cost: 8, kind: :victory },
  { name: "村", cost: 3, kind: :action },
  { name: "鍛冶屋", cost: 4, kind: :action },
  { name: "市場", cost: 5, kind: :action },
  { name: "研究所", cost: 5, kind: :action },
  { name: "木こり", cost: 3, kind: :action },
  { name: "祝祭", cost: 5, kind: :action },
  { name: "堀", cost: 2, kind: :action },
  { name: "地下貯蔵庫", cost: 2, kind: :action },
].each do |attrs|
  card = Card.find_or_create_by!(name: attrs[:name]) { |c| c.cost = attrs[:cost] }
  card.card_kinds.find_or_create_by!(kind: attrs[:kind])
end