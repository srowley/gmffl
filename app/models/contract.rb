class Contract < ApplicationRecord

  belongs_to :franchise
  belongs_to :player

  def dead_cap
    return 0 if roster_status == "TAXI_SQUAD"
    if contract_type == "Locked"
      current_year_hit = (salary/2.to_f).ceil
      future_years_hit = (contract_years_remaining * salary / 2.to_f).ceil
      current_year_hit + future_years_hit
    else
      contract_type == "Guaranteed"
      current_salary = salary
      cap_hit = current_salary.to_f / 2
      contract_years_remaining.times do |n|
        salary = (current_salary * 1.05).ceil
        cap_hit += (current_salary / 10.0).ceil
      end
      cap_hit.to_i
    end
  end

  def stats
    player.stats.first ? player.stats.first : Stat.new
  end

  def holdout_eligible?
     top_player? && !(rookie_contract? || grandfathered_contract?) && contract_end > franchise.league.year
  end

  def contract_years_remaining
    contract_end - franchise.league.year
  end

  def contract_type
    if contract_terms[1] == "L"
      "Locked"
    else
      "Guaranteed"
    end
  end

  def salary_schedule
    schedule =  {}
    schedule[franchise.league.year] = salary
    if contract_type == "Guaranteed"
      contract_years_remaining.times do |n|
        year = franchise.league.year + n 
        schedule[year + 1] = (schedule[year] * 1.05).ceil
      end
    else
      contract_years_remaining.times do |n|
        year = franchise.league.year + n 
        schedule[year + 1] = salary 
      end
    end
    schedule
  end
  
  def rookie_contract?
    contract_terms.include? "R"
  end

  def grandfathered_contract?
    contract_terms.include? "*"
  end

  def top_player?
    thresholds = { QB: 12, RB: 24, WR: 36, TE: 12 }
    return false unless stats.rank
    stats.rank <= thresholds[stats.position.to_sym]
  end

  def contract_end
    contract_terms[3..6].to_i
  end

  def contract_length
    contract_terms[0].to_i
  end

  def contract_start
    contract_end - contract_length + 1
  end
end
