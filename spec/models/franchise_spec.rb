require 'rails_helper'

describe Franchise do
  pending "#name"
  pending "#owner"

  before(:each) do
    @active_player = Player.new(id: 1, roster_status: "ROSTER")
    @ts_player = Player.new(id: 2, roster_status: "TAXI_SQUAD", contract: "2G-2018")
    @franchisable_player = Player.new(id: 3, roster_status: "TAXI_SQUAD", contract: "2G-2017")
    @franchise = Franchise.new(players: [@active_player, @ts_player, @franchisable_player])
  end

  describe "#active_roster" do
    it "returns array of active roster players" do
      expect(@franchise.active_roster.length).to eq(1)
      expect(@franchise.active_roster[0].id).to eq(1)
    end
  end 

  describe "#taxi_squad" do
    it "returns array of taxi_squad players" do
      expect(@franchise.taxi_squad.length).to eq(1)
      expect(@franchise.taxi_squad[0].id).to eq(2)
    end
  end

  describe "franchisable" do
    it "returns an array of franchisable players" do
      expect(@franchise.pending_franchise_tag.length).to eq(1)
      expect(@franchise.pending_franchise_tag[0].id).to eq(3)
    end
  end
end 
