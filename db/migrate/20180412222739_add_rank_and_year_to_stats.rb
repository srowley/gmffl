class AddRankAndYearToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :rank, :integer
    add_column :stats, :year, :integer
  end
end
