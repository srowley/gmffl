class Player < ApplicationRecord

  self.primary_key = "player_id"

  def stats
    Stat.where(player_id: player_id).first ? Stat.where(player_id: player_id).first : Stat.new
  end
end
