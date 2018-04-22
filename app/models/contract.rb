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
     dead_cap_calc(0.5, 0.5)
    else
      dead_cap_calc(0.25, 0.1)
    end
  end

  def extended?
    contract_terms.include? "E"
  end

  def guaranteed?
    type == "Guaranteed"
  end

  def holdout_eligible?
     top_player? && !(rookie_contract? || grandfathered_contract?) && last_year > franchise.league.year
  end

  def years_remaining
    last_year - franchise.league.year
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
    player.holdout_rank(franchise.league.year - 1) <= thresholds[player.position.to_sym]
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

  def dead_cap_calc(first_year_pct, future_years_pct)
    salary_hash = salary_schedule
    league_year = franchise.league.year
    current_year_hit = (salary_hash[league_year]* first_year_pct).ceil
    remaining_term = salary_hash.delete_if {|k,v| k == league_year }
    remaining_hit = (remaining_term.values.sum * future_years_pct).ceil
    current_year_hit + remaining_hit
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
    schedule.delete_if {|k,v| k < franchise.league.year || k > last_year }
    schedule
  end
end
