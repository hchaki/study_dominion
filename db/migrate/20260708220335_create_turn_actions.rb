class CreateTurnActions < ActiveRecord::Migration[8.1]
  def change
    create_table :turn_actions do |t|
      t.references :turn, null: false, foreign_key: true
      t.references :game_card, null: false, foreign_key: true
      t.integer :action
      t.integer :position

      t.timestamps
    end
  end
end
