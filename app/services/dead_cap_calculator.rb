class DeadCapCalculator

  def initialize(contract)
    @contract = contract
  end

  def call
    return 0 if contract.roster_status == "TAXI_SQUAD"
    if contract.type == "Locked"
      calc_dead_cap(0.5, 0.5)
    else
      calc_dead_cap(0.25, 0.1)
    end
  end

  private

  attr_reader :contract

  def calc_dead_cap(first_year_pct, future_years_pct)
    without_deferrals = Contract.new(contract.attributes)
    without_deferrals.franchise.league = contract.franchise.league
    # I don't understand why the line below is necessary
    without_deferrals = without_deferrals.extension.extended_contract if without_deferrals.extended?
    without_deferrals.events.delete_if { |e| e.type == "Deferred" }
    salary_hash = without_deferrals.salary_schedule
    current_year_hit = (salary_hash[league_year]* first_year_pct).ceil
    remaining_term = salary_hash.delete_if {|k,v| k == league_year }
    remaining_hit = (remaining_term.values.sum * future_years_pct).ceil
    current_year_hit + remaining_hit + deferred_salary_adjustment
  end

  def deferred_salary_adjustment
    deferral_events = contract.events.select { |e| e.type == "Deferred" && e.adjustment_schedule[league_year] }
    adjustment = deferral_events.sum { |d| (d.amount * 1.25).ceil }
  end  

  def league_year
    contract.franchise.league.year
  end

end
