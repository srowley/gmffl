class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table(:contracts, id: false) do |t|
      t.integer :player_id
      t.string :contract_terms
      t.string :roster_status
      t.integer :acquired_cost
      t.string :notes
      t.integer :salary
      t.string :franchise_id
    end
  end
end
