class AddCpuToGamePlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :game_players, :cpu, :boolean, default: false, null: false
  end
end
