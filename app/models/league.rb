require 'open-uri'

class League
 include ActiveModel::Model

 attr_accessor :id, :roster_url, :franchises, :year, :players_url, :franchises_url, :adjustments_url

  def initialize(id = nil, year = nil)
    self.id = id
    self.year = year
    self.roster_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{id}"
    self.players_url = "https://www70.myfantasyleague.com/#{year}/export?TYPE=players&DETAILS=&SINCE=&PLAYERS=&JSON=0"
    self.franchises_url = "https://www61.myfantasyleague.com/#{year}/export?TYPE=league&L=#{id}"
    self.adjustments_url = "https://www61.myfantasyleague.com/#{year}/export?TYPE=salaryAdjustments&L=#{id}"
  end

  def import_contracts
    Contract.delete_all
    doc = Nokogiri::XML(open(roster_url))
    franchise_nodes = doc.xpath("//franchise")
    franchise_nodes.each do |f|
      contracts = f.xpath("./player")
      contracts.each do |c|
        Contract.create(player_id:              c["id"].to_i,
                        contract_terms:         c["contractStatus"],
                        roster_status:          c["status"],
                        acquired_cost:          c["contractYear"].to_i,
                        notes:                  c["contractInfo"],
                        salary:                 c["salary"].to_i,
                        franchise_id:           f["id"])
      end
    end
  end

  def import_adjustments
    Adjustment.delete_all
    doc = Nokogiri::XML(open(adjustments_url))
    adjustment_nodes = doc.xpath("//salaryAdjustment[@timestamp>1520013527]")
    adjustment_nodes.each do |a|
      Adjustment.create(amount:             a["amount"].to_i,
                        description:        a["description"],
                        franchise_id:       a["franchise_id"]) 
      end
  end
  
  def import_players
    Player.delete_all
    doc = Nokogiri::XML(open(players_url))
    player_nodes = doc.xpath("//player")
    player_nodes.each do |p| 
      Player.create(player_id: p["id"], name: p["name"], position: p["position"]) if ["QB", "RB", "WR", "TE"].include? p["position"]
    end
  end

  def import_franchises
    Franchise.delete_all
    doc = Nokogiri::XML(open(franchises_url))
    franchise_nodes = doc.xpath("//franchise")
    franchise_nodes.each do |f| 
      Franchise.create(franchise_id: f["id"], name: f["name"])
    end
  end
end
