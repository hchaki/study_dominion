# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_08_220335) do
  create_table "card_kinds", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.integer "kind"
    t.datetime "updated_at", null: false
    t.index ["card_id", "kind"], name: "index_card_kinds_on_card_id_and_kind", unique: true
    t.index ["card_id"], name: "index_card_kinds_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.integer "cost"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "game_cards", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "game_player_id"
    t.integer "place"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_game_cards_on_card_id"
    t.index ["game_id"], name: "index_game_cards_on_game_id"
    t.index ["game_player_id"], name: "index_game_cards_on_game_player_id"
  end

  create_table "game_players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.integer "seat_order"
    t.datetime "updated_at", null: false
    t.index ["game_id", "player_id"], name: "index_game_players_on_game_id_and_player_id", unique: true
    t.index ["game_id", "seat_order"], name: "index_game_players_on_game_id_and_seat_order", unique: true
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["player_id"], name: "index_game_players_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "actions_remaining"
    t.integer "buys_remaining"
    t.integer "coins"
    t.datetime "created_at", null: false
    t.integer "status"
    t.integer "turn_phase"
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "turn_actions", force: :cascade do |t|
    t.integer "action"
    t.datetime "created_at", null: false
    t.integer "game_card_id", null: false
    t.integer "position"
    t.integer "turn_id", null: false
    t.datetime "updated_at", null: false
    t.index ["game_card_id"], name: "index_turn_actions_on_game_card_id"
    t.index ["turn_id"], name: "index_turn_actions_on_turn_id"
  end

  create_table "turns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "game_player_id", null: false
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["game_id", "number"], name: "index_turns_on_game_id_and_number", unique: true
    t.index ["game_id"], name: "index_turns_on_game_id"
    t.index ["game_player_id"], name: "index_turns_on_game_player_id"
  end

  add_foreign_key "card_kinds", "cards"
  add_foreign_key "game_cards", "cards"
  add_foreign_key "game_cards", "game_players"
  add_foreign_key "game_cards", "games"
  add_foreign_key "game_players", "games"
  add_foreign_key "game_players", "players"
  add_foreign_key "turn_actions", "game_cards"
  add_foreign_key "turn_actions", "turns"
  add_foreign_key "turns", "game_players"
  add_foreign_key "turns", "games"
end
