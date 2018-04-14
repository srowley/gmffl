class FranchisesController < ApplicationController
  def index
    league_id = params[:league]
    year = params[:year].to_i
    league = League.new(league_id, year)
    @franchises = league.import_contracts
  end
end
