require 'rails_helper'

describe Player do

  describe "::import_xml" do
    it "imports MFL player data" do
      league = League.new(42618, 2018)
      league.players_url = "#{Rails.root}/spec/fixtures/files/players.xml"
      Player.import_xml(league)
      expect(Player.count).not_to eq(0)
    end
  end
end
