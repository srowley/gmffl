require 'rails_helper'

describe League do

  describe "#import_contracts" do
    it "imports MFL roster data" do
      Franchise.create(franchise_id: "0001")
      league = League.new(42618, 2018)
      league.roster_url =  Rails.root.to_s + "/spec/fixtures/files/rosters.xml"
      franchises = league.import_contracts
      expect(franchises.length).to eq(1)
      expect(franchises[0].id).to eq("0001")
    end
  end

  describe "#import_players" do
    it "imports MFL player data" do
      league = League.new(42618, 2018)
      league.players_url = Rails.root.to_s + "/spec/fixtures/files/players.xml"
      league.import_players
      expect(Player.count).not_to eq(0)
    end
  end
end
