class CreateGamePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :game_players do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :seat_order

      t.timestamps
    end
    add_index :game_players, [:game_id, :player_id], unique: true
    add_index :game_players, [:game_id, :seat_order], unique: true
  end
end
