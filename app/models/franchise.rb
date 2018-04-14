class Franchise < ApplicationRecord

  self.primary_key = "franchise_id"

  attr_accessor :contracts, :league, :adjustments

  def active_roster(position = nil)
    all = contracts.select{ |p| p.roster_status == "ROSTER" }
    all = all.sort_by { |c| c.player.name }
    !position ? all : all.select{|c| c.player.position == position }
  end

  def taxi_squad(position = nil)
    all = contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end != (league.year - 1) }
    all = all.sort_by { |c| c.player.name }
    !position ? all : all.select{|c| c.player.position == position }
  end

  def pending_franchise_tag(position = nil) 
    all = contracts.select{ |p| p.roster_status == "TAXI_SQUAD" && p.contract_end == league.year - 1}
    all = all.sort_by { |c| c.player.name }
    !position ? all : all.select{|c| c.player.position == position }
  end

  def salary(roster = nil, position = nil )
    selected_contracts = roster ? self.send(roster, position) : self.contracts
    salaries = selected_contracts.map { |p| p.salary }
    salaries.inject(:+) 
  end
 
  def total_adjustments
    return 0 if adjustments.empty?
    adjustment_amounts = adjustments.map { |a| a.amount }
    adjustment_amounts.inject(:+)
  end
end
