class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :status
      t.integer :turn_phase
      t.integer :actions_remaining
      t.integer :buys_remaining
      t.integer :coins

      t.timestamps
    end
  end
end
