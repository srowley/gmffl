class SalaryCalculator

  def initialize(contract)
    @contract = contract
  end

  def call
     if @contract.extended?
       SalaryCalculator.new(contract.extension.original_contract).call.merge(SalaryCalculator.new(contract.extension.extended_contract).call)
     else
       salary_schedule
     end
  end

  private

  attr_reader :contract

  def base_salary
    schedule = {}
    if contract.guaranteed?
      schedule = legacy_guaranteed_salary
      (2017..contract.last_year).each do |year|
        schedule[year + 1] = (schedule[year].to_i * 1.05).ceil
      end
    else
      schedue = { contract.start_year => contract.acquired_cost }
      (contract.start_year..contract.last_year).each do |y|
        schedule[y] = contract.acquired_cost
      end
    end
    schedule.delete_if {|k,v| k > contract.last_year }
  end    

  def salary_schedule
    all_adjustments = {}
    contract.events.each do |a|
      all_adjustments = all_adjustments.merge(a.adjustment_schedule) { |year, old, new| old + new }
    end
    all_adjustments = all_adjustments.merge(base_salary) { |year, old, new| old + new }
    all_adjustments
  end

  def legacy_guaranteed_salary
    schedule = {}
    schedule[contract.start_year] = contract.acquired_cost
    legacy_adjustment = contract.years_long > 4 ? 2 : 0
    ((contract.start_year)..2017).each do |year|
      schedule[year + 1] = schedule[year].to_i + [(schedule[year].to_i * 0.05).ceil, legacy_adjustment].max
    end
    schedule
  end

  def league_year
    contract.franchise.league.year
  end
end
