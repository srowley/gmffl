class Contract < ApplicationRecord

  belongs_to :franchise
  belongs_to :player
  
  attr_accessor :events

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

  def deferrals 
    events.select { |e| e.type == "Deferred" }
  end
    
  def advances
    events.select { |e| e.type == "Advanced" }
  end
    
  def transfers 
    events.select { |e| e.type == "Transferred" }
  end

  def dead_cap
    return 0 if roster_status == "TAXI_SQUAD"
    if type == "Locked"
      current_year_hit = (salary/2.to_f).ceil
      future_years_hit = (years_remaining * salary / 2.to_f).ceil
      current_year_hit + future_years_hit
    else
      type == "Guaranteed"
      current_salary = salary
      cap_hit = current_salary.to_f / 2
      years_remaining.times do |n|
        salary = (current_salary * 1.05).ceil
        cap_hit += (current_salary / 10.0).ceil
      end
      cap_hit.to_i
    end
  end

  def legacy_guaranteed?
    guaranteed? && start_year < 2018
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
    SalaryCalculator.new(self).call
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

  def parse_notes
    @events = []
    events_match = /\[.+\]/.match(notes)
    if events_match
      events_list = events_match.to_s[1..-2].split(";")
      events_list.each do |e|
        args = e.split(":")
        @events << Event.new(args[0], args[1].to_i, args[2].to_i, self)
      end
    end
    @events
  end
end
