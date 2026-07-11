class CreateGameCards < ActiveRecord::Migration[8.1]
  def change
    create_table :game_cards do |t|
      t.references :game, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.references :game_player, foreign_key: true
      t.integer :place
      t.integer :position

      t.timestamps
    end
  end
end
