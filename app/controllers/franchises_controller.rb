class FranchisesController < ApplicationController
  def index
    league_id = params[:league]
    year = params[:year].to_i
    league = League.new(league_id, year)
    if session[:same].nil?
      Contract.import_xml(league)
      Adjustment.import_xml(league)
      session[:same] = true
    end
    @franchises = Franchise.all.includes(:adjustments, contracts: :player).to_a
    @franchises.each { |f| f.league = league }
    @franchises
  end
end
