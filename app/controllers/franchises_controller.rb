class FranchisesController < ApplicationController
  def index
    league = League.new(roster_url: Rails.root.to_s + "/spec/fixtures/files/rosters.xml", year: 2018)
#    @league = League.new(roster_url: "http://www61.myfantasyleague.com/2018/export?TYPE=rosters&L=42618")
    league.import_rosters
    @franchises = league.franchises
  end
end
