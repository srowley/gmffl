class Player < ApplicationRecord

  self.primary_key = "player_id"
  has_one :contract
  has_many :stats

end
