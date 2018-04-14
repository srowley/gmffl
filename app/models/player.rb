class Player < ApplicationRecord

  self.primary_key = "player_id"
  has_many :stats

end
