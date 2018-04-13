class Franchise
  include ActiveModel::Model
  attr_accessor :id, :contracts, :league

  def active_roster
    @contracts.select{ |p| p.roster_status == "ROSTER" }
  end

  def taxi_squad 
    @contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end != (league.year - 1) }
  end

  def pending_franchise_tag 
    @contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end == league.year - 1}
  end

  def salary(roster = nil )
    selected_contracts = roster ? self.send(roster) : self.contracts
    salaries = selected_contracts.map { |p| p.salary }
    salaries.inject(:+) 
  end
end
