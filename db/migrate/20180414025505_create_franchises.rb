class CreateFranchises < ActiveRecord::Migration[5.1]
  def change
    create_table(:franchises, id: false) do |t|
      t.string :franchise_id, null: false
      t.string :name
    end

    add_index(:franchises, :franchise_id, unique: true)
  end
end
