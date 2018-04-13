require 'rails_helper'

describe Franchise do
  pending "#name"
  pending "#owner"

  before(:each) do
    @league = League.new(42618, 2018)
    @active_contract= Contract.new(player_id: 1, roster_status: "ROSTER")
    @ts_contract = Contract.new(player_id: 2, roster_status: "TAXI_SQUAD", contract_terms: "2G-2018")
    @franchisable_contract = Contract.new(player_id: 3, roster_status: "TAXI_SQUAD", contract_terms: "2G-2017")
    @franchise = Franchise.new(contracts: [@active_contract, @ts_contract, @franchisable_contract], league: @league)
  end

  describe "#active_roster" do
    it "returns array of active roster contracts" do
      expect(@franchise.active_roster.length).to eq(1)
      expect(@franchise.active_roster[0].player_id).to eq(1)
    end
  end 

  describe "#taxi_squad" do
    it "returns array of taxi_squad contracts" do
      expect(@franchise.taxi_squad.length).to eq(1)
      expect(@franchise.taxi_squad[0].player_id).to eq(2)
    end
  end

  describe "franchisable" do
    it "returns an array of franchisable contracts" do
      expect(@franchise.pending_franchise_tag.length).to eq(1)
      expect(@franchise.pending_franchise_tag[0].player_id).to eq(3)
    end
  end
end 
