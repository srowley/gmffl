class Extension

  attr_accessor :contract, :year, :original_terms

  def initialize(year, original_terms, contract)
    @year, @original_terms, @contract = year, original_terms, contract
  end

  def extended_contract
    new_acquired_cost = SalaryCalculator.new(original_contract).call[original_contract.last_year]
    extension = Contract.new(player: contract.player,
                             franchise: contract.franchise,
                             acquired_cost: new_acquired_cost,
                             contract_terms: contract.years_long.to_s + contract.type[0] + "-" + contract.last_year.to_s,
                             notes: contract.notes.remove("Extended:#{year}:#{original_terms}"))
    extension.franchise.league = contract.franchise.league
    extension
  end

  def original_contract
    original = Contract.new(player: contract.player,
                             franchise: contract.franchise,
                             acquired_cost: contract.acquired_cost,
			     contract_terms: original_terms.remove("E"),
                             notes: contract.notes.remove("Extended:#{year}:#{original_terms}"))
    original.franchise.league = contract.franchise.league
    original.events.delete_if {|e| e.year >= original.last_year }
    original
  end
end

