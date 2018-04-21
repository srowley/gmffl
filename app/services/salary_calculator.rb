class SalaryCalculator

  def initialize(contract)
    @contract = contract
  end

  def call
     salary_schedule
  end

  private

  attr_reader :contract

#  def schedule_for_extended_contract
#    original_contract = @contract
#    original_contract_terms = ....get from notes....
#    original_contract.contract_terms = original_contract_terms
#    #remove extension event
#    original_contract_schedule = original_contract.salary_schedule
#
#    extension = @contract
#    extension_length = @contract.last_year - original_contract.last_year
#    extension.contract_terms = extension_length + extension_type[0] + "-" + original_contract.last_year
#    extension.acquired_cost = ...get from original contract...
#    #remove extension event
#    extension_schedule = extension.salary_schedule
#    
#    original_contract_schedule.merge(extension_schedule)
#  end

  def base_salary
    schedule = {}
    if contract.guaranteed?
      schedule = legacy_guaranteed_salary
      (2017..contract.last_year).each do |year|
        schedule[year + 1] = (schedule[year].to_i * 1.05).ceil
      end
    else
      schedue = { contract.start_year => contract.acquired_cost }
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
