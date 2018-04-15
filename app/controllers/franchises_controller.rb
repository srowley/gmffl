class FranchisesController < ApplicationController
  def index
    league_id = params[:league]
    year = params[:year].to_i
    league = League.new(league_id, year)
    Contract.import_xml(league)
    Adjustment.import_xml(league)
    @franchises = Franchise.all.to_a
    @franchises.each { |f| f.league = league }
    @franchises
  end
end
