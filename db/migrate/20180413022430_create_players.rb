class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table(:players, id: false) do |t|
      t.integer :player_id, null: false
      t.string :name
      t.string :team
    end

    add_index(:players, :player_id, unique: true)
  end
end
