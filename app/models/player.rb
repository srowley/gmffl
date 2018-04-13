class Player
  include ActiveModel::Model
  attr_accessor :id, :contract, :roster_status, :acquired_cost, :notes, :salary, :franchise

  def dead_cap
    return 0 if @roster_status == "TAXI_SQUAD"
    if self.contract_type == "Locked"
      current_year_hit = (@salary/2.to_f).ceil
      future_years_hit = (contract_years_remaining * @salary / 2.to_f).ceil
      current_year_hit + future_years_hit
    else
      self.contract_type == "Guaranteed"
      salary = @salary
      cap_hit = salary.to_f / 2
      contract_years_remaining.times do |n|
        salary = (salary * 1.05).ceil
        cap_hit += (salary / 10.0).ceil
      end
      cap_hit.to_i
    end
  end

  def stats
    Stat.where(player_id: id).first ? Stat.where(player_id: id).first : Stat.new
  end

  def holdout_eligible?
     !(rookie_contract? || grandfathered_contract?) && contract_end > franchise.league.year
  end

  def contract_years_remaining
    contract_end - franchise.league.year
  end

  def contract_type
    if @contract[1] == "L"
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
    @contract.include? "R"
  end

  def grandfathered_contract?
    @contract.include? "*"
  end

  def contract_end
    @contract[3..6].to_i
  end

  def contract_length
    @contract[0].to_i
  end

  def contract_start
    contract_end - contract_length + 1
  end
end
