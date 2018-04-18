class SalaryCalculator

  def initialize(contract)
    @contract = contract
  end

  def call
    adjustments? ? salary_schedule : base_salary
  end

  private

  attr_reader :contract

  def adjustments?
    /\[.+\]/.match(contract.notes)
  end

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


  # Takes a string and pulls out the portion in brackets
  # Expects this part to be in form xx:yy:zz;aa:bb:cc
  # wnere "xx" is "Deferred", "Transferred" or "Advanced",
  # "yy" is the year of the adjustment and
  # "zz" is the amount, and ";" delimits each adjustment
  # 
  # This string is transformed into an array of arrays for
  # each type - e.g. [[xx, yy, zz], [gg, hh, ii]],
  # and is sent to processing methods that return a hash of
  # annual adjustments, e.g. {2017=>5, 2018=>1}
  def salary_schedule
    adjustments = /\[.+\]/.match(contract.notes)
    adjustments = adjustments.to_s[1..-2].split(";")
    adjustments = adjustments.map { |a| a.split(":")}
    adjustments.map! { |a| [a[0], a[1].to_i, a[2].to_i] }

    advances, transfers, deferrals = {}, {}, {}
    advances = process_advances(adjustments.select {|a| a[0] == "Advanced"}) if adjustments.flatten.include?("Advanced")
    transfers = process_transfers(adjustments.select {|a| a[0] == "Transferred"}) if adjustments.flatten.include?("Transferred")
    deferrals = process_deferrals(adjustments.select {|a| a[0] == "Deferred"}) if adjustments.flatten.include?("Deferred")

    combine_adjustments(deferrals, transfers, advances)
  end

  def combine_adjustments(deferrals, transfers, advances)
    years = (base_salary.keys + deferrals.keys + transfers.keys + advances.keys).uniq
    salaries = {}
    years.each { |y| salaries[y] = base_salary[y] + deferrals[y].to_i + transfers[y].to_i + advances[y].to_i }
    salaries
  end

  def process_deferrals(deferrals)
    deferral_adjustments = {}
    deferrals.each do |d|
      deferral_adjustments[d[1]] = deferral_adjustments[d[1]].to_i - d[2]
      deferral_adjustments[d[1] + 1] = deferral_adjustments[d[1] + 1].to_i + (d[2] * 1.25).ceil.to_i
    end
    deferral_adjustments.delete_if {|k,v| k < league_year || k > contract.last_year }
  end
    
  def process_advances(advances)
    advance_adjustments = {}
    advances.each do |a|
      advance_adjustments[a[1]] = advance_adjustments[a[1]].to_i + a[2] 
      term = contract.last_year - a[1]                              
      ((a[1] + 1)..contract.last_year).each { |y| advance_adjustments[y] = advance_adjustments[y].to_i - a[2]/term }
      remaining_adjustment_years = a[2] % term  
      remaining_adjustment_years.times { |y| advance_adjustments[contract.last_year - y] = advance_adjustments[contract.last_year - y].to_i - 1 }
    end
    advance_adjustments.delete_if {|k,v| k < league_year || k > contract.last_year }
  end

  def process_transfers(transfers)
    transfer_adjustments = {}
    transfers.each do |t|
     transfer_adjustments[t[1]] = transfer_adjustments[t[1]].to_i - t[2]
    end
    transfer_adjustments.delete_if {|k,v| k < league_year || k > contract.last_year }
  end

  def league_year
    contract.franchise.league.year
  end
end
