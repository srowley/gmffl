class Franchise
  include ActiveModel::Model
  attr_accessor :id, :players, :league

  def active_roster
    @players.select{ |p| p.roster_status == "ROSTER" }
  end

  def taxi_squad 
    @players.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end != (league.year - 1) }
  end

  def pending_franchise_tag 
    @players.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end == league.year - 1}
  end

  def salary(roster = nil )
    selected_players = roster ? self.send(roster) : self.players
    salaries = selected_players.map { |p| p.salary }
    salaries.inject(:+) 
  end
end
