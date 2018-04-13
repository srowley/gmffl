class FranchisesController < ApplicationController
  def index
#    league = League.new(roster_url: Rails.root.to_s + "/spec/fixtures/files/rosters.xml", year: 2018)
    league_id = params[:league]
    year = params[:year].to_i
#    league = League.new(roster_url: "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{league_id}", year: year.to_i)
    league = League.new(league_id, year)
    league.import_contracts
    @franchises = league.franchises
  end
end
