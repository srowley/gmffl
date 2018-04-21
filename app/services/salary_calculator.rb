class SalaryCalculator

  def initialize(contract)
    @contract = contract
  end

  def call
     salary_schedule
  end

  private

  attr_reader :contract

  def base_salary
    schedule =  {}
    schedule[contract.start_year] = contract.acquired_cost
    if contract.guaranteed?
      contract.years_long.times do |n|
        year = contract.start_year + n
        schedule[year + 1] = (schedule[year] * 1.05).ceil
      end
    else
      (league_year..contract.last_year).each do |y|
        schedule[y] = contract.acquired_cost
      end
    end
    schedule.delete_if {|k,v| k < league_year || k > contract.last_year }
  end    

  def salary_schedule
    all_adjustments = {}
    contract.events.each do |a|
      all_adjustments = all_adjustments.merge(a.adjustment_schedule) { |year, old, new| old + new }
    end
    all_adjustments = all_adjustments.merge(base_salary) { |year, old, new| old + new }
    all_adjustments
  end

  def league_year
    contract.franchise.league.year
  end
end
