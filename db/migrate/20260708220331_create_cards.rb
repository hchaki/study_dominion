class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.integer :cost

      t.timestamps
    end
  end
end
