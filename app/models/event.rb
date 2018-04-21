class Event

  attr_accessor:type, :year, :amount, :contract

  def initialize(type, year, amount, contract)
   @type, @year, @amount, @contract = type, year, amount, contract
  end

  def adjustment_schedule
    case
    when type == "Deferred"
       deferral_schedule
    when type == "Advanced"
       advance_schedule
    when type == "Transferred"
       transfer_schedule
    else
       {}
    end
  end

  private

  def deferral_schedule
    deferral = {}
    deferral[year] = deferral[year].to_i - amount
    deferral[year + 1] = deferral[year + 1].to_i + (amount * 1.25).ceil.to_i
    trim_years(deferral)
  end

  def advance_schedule
    advance = {}
    advance[year] = advance[year].to_i + amount 
    term = contract.last_year - year
    ((year + 1)..contract.last_year).each { |y| advance[y] = advance[y].to_i - amount/term }
    remaining_adjustment_years = amount % term
    remaining_adjustment_years.times { |y| advance[contract.last_year - y] = advance[contract.last_year - y].to_i - 1 }
    trim_years(advance)
  end

  def transfer_schedule
    transfer = {}
    transfer[year] = -1 * amount
    trim_years(transfer)
  end
  
  def trim_years(schedule)
    schedule.delete_if {|k,v| k < contract.franchise.league.year || k > contract.last_year }
    schedule
  end
end
