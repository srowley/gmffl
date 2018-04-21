require 'rails_helper'

describe Extension do
  before(:each) do
    @league = League.new(42618, 2018)
    @franchise = Franchise.create(league: @league, franchise_id: "0001")
    @player = Player.create(position: "QB", player_id: 1)
  end

  describe "#original_contract" do
    it "returns a contract object matching the original contract" do
      notes = "2016: Extended from 2G-2016 ($3 initial) to 3L-2018 ($4/yr); 2017: Stashed; 2018: HOLDING OUT ($34) [Extended:2016:2G-2016]"
      contract = Contract.create(contract_terms: "3L-2018", franchise: @franchise, player: @player, notes: notes, acquired_cost: 3)
      original = contract.extension.original_contract
      expect(original.contract_terms).to eq("2G-2016")
      expect(original.acquired_cost).to eq(3)
      expect(original.notes).to eq("2016: Extended from 2G-2016 ($3 initial) to 3L-2018 ($4/yr); 2017: Stashed; 2018: HOLDING OUT ($34) []")
      expect(contract.extension.original_contract.salary_schedule).to eq({ 2015 => 3, 2016 => 4 })
    end
  end 
end
