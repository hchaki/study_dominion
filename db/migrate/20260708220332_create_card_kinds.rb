class CreateCardKinds < ActiveRecord::Migration[8.1]
  def change
    create_table :card_kinds do |t|
      t.references :card, null: false, foreign_key: true
      t.integer :kind

      t.timestamps
    end
    add_index :card_kinds, [:card_id, :kind], unique: true
  end
end
