class Franchise
  include ActiveModel::Model
  attr_accessor :id, :players

  def active_roster
    @players.select{ |p| p.roster_status == "ROSTER" }
  end

  def taxi_squad 
    @players.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end != (2018 - 1) }
  end

  def pending_franchise_tag 
    @players.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end == 2017}
  end
end
