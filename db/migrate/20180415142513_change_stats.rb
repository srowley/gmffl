class ChangeStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :week, :integer
    remove_column :stats, :rank, :integer
    remove_column :stats, :position, :string
  end
end
