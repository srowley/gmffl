class Contract < ApplicationRecord

  belongs_to :franchise
  belongs_to :player
  
  attr_accessor :events, :extension

  after_initialize :parse_notes

  def self.import_xml(league)
    Contract.delete_all
    doc = Nokogiri::XML(open(league.roster_url))
    contract_objects = []
    franchise_nodes = doc.xpath("//franchise")
    franchise_nodes.each do |f|
      contracts = f.xpath("./player")
      contracts.each do |c|
        contract_objects << Contract.new(player_id:              c["id"].to_i,
                                         contract_terms:         c["contractStatus"],
                                         roster_status:          c["status"],
                                         acquired_cost:          c["contractYear"].to_i,
                                         notes:                  c["contractInfo"],
                                         salary:                 c["salary"].to_i,
                                         franchise_id:           f["id"])
      end
    end
    Contract.import contract_objects
  end

  def dead_cap
    return 0 if roster_status == "TAXI_SQUAD"
    if type == "Locked"
      calc_dead_cap(0.5, 0.5)
    else
      calc_dead_cap(0.25, 0.1)
    end
  end

  def extended?
    contract_terms.include? "E"
  end

  def guaranteed?
    type == "Guaranteed"
  end

  def holdout_eligible?
     top_player? && !(rookie_contract? || grandfathered_contract?) && last_year > league_year
  end

  def years_remaining
    last_year - league_year
  end

  def type
    if contract_terms[1] == "L"
      "Locked"
    else
      "Guaranteed"
    end
  end

  def salary_schedule
    trim_years(SalaryCalculator.new(self).call)
  end
  
  def rookie_contract?
    contract_terms.include? "R"
  end

  def grandfathered_contract?
    contract_terms.include? "*"
  end

  def top_player?
    thresholds = { QB: 12, RB: 24, WR: 36, TE: 12 }
    player.holdout_rank(league_year - 1) <= thresholds[player.position.to_sym]
  end

  def last_year
    contract_terms[3..6].to_i
  end

  def years_long 
    contract_terms[0].to_i
  end

  def start_year
    last_year - years_long + 1
  end

  private

  def calc_dead_cap(first_year_pct, future_years_pct)
    without_deferrals = Contract.new(self.attributes)
    without_deferrals.franchise.league = franchise.league
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
    deferral_events = events.select { |e| e.type == "Deferred" && e.adjustment_schedule[league_year] }
    adjustment = deferral_events.sum { |d| (d.amount * 1.25).ceil } 
  end

  def parse_notes
    @events = []
    events_match = /\[.+\]/.match(notes)
    if events_match
      events_list = events_match.to_s[1..-2].split(";")
      events_list.each do |e|
        args = e.split(":")
        if args[0].include? "Extended"
          @extension = Extension.new(args[1], args[2], self)
        else
          @events << Event.new(args[0], args[1].to_i, args[2].to_i, self)
        end
      end
    end
  end

  def trim_years(schedule)
    schedule.delete_if {|k,v| k < league_year || k > last_year }
    schedule
  end

  def league_year
    franchise.league.year
  end
end

