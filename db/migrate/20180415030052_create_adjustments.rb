class CreateAdjustments < ActiveRecord::Migration[5.1]
  def change
    create_table :adjustments do |t|
      t.integer :amount
      t.string :description
      t.string :franchise_id
    end
  end
end
