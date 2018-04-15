require 'rails_helper'

describe Adjustment do

  describe "::import_xml" do
    it "imports all the approprite adjustment records" do
      league = League.new(42618, 2018)
      Franchise.import_xml(league)
      league.adjustments_url = "#{Rails.root}/spec/fixtures/files/adjustments.xml"
      Adjustment.import_xml(league)
      expect(Adjustment.count).to eq(8)
    end
  end
end
