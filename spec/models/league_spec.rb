require 'rails_helper'

describe League do

  describe "#import_rosters" do
    it "imports MFL roster data" do
      league = League.new(roster_url: Rails.root.to_s + "/spec/fixtures/files/rosters.xml")
      league.import_rosters
      expect(league.franchises.length).to eq(12)
      expect(league.franchises[0].id).to eq("0001")
    end
  end
end
