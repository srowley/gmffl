class Franchise < ApplicationRecord

  self.primary_key = "franchise_id"

  attr_accessor :contracts, :league, :adjustments

  def active_roster
    contracts.select{ |p| p.roster_status == "ROSTER" }
  end

  def taxi_squad 
    contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end != (league.year - 1) }
  end

  def pending_franchise_tag 
    contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end == league.year - 1}
  end

  def salary(roster = nil )
    selected_contracts = roster ? self.send(roster) : self.contracts
    salaries = selected_contracts.map { |p| p.salary }
    salaries.inject(:+) 
  end
 
  def total_adjustments
    return 0 if adjustments.empty?
    adjustment_amounts = adjustments.map { |a| a.amount }
    adjustment_amounts.inject(:+)
  end
end
