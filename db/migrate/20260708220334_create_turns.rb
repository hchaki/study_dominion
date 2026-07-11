class CreateTurns < ActiveRecord::Migration[8.1]
  def change
    create_table :turns do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :number
      t.references :game_player, null: false, foreign_key: true

      t.timestamps
    end
    add_index :turns, [:game_id, :number], unique: true
  end
end
