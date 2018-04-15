require 'rails_helper'

describe League do

  describe "#import_contracts" do
    it "imports MFL roster data" do
      #would be great to raise error on import fail due to validations
      league = League.new
      league.franchises_url = "#{Rails.root}/spec/fixtures/files/franchises.xml"
      Franchise.import_xml(league)
      league.players_url = "#{Rails.root}/spec/fixtures/files/players.xml"
      league.import_players
      league.roster_url = "#{Rails.root}/spec/fixtures/files/rosters.xml"
      league.import_contracts
      expect(Contract.count).to eq(233)
    end
  end

  describe "#import_players" do
    it "imports MFL player data" do
      league = League.new
      league.players_url = "#{Rails.root}/spec/fixtures/files/players.xml"
      league.import_players
      expect(Player.count).not_to eq(0)
    end
  end
end
