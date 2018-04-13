class CreateStats < ActiveRecord::Migration[5.1]
  def change
    create_table :stats do |t|
      t.integer :score
      t.string :position
      t.references :player

      t.timestamps
    end
  end
end
