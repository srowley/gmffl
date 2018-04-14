require 'open-uri'

class League
 include ActiveModel::Model

 attr_accessor :id, :roster_url, :franchises, :year, :players_url, :franchises_url

  def initialize(id = nil, year = nil)
    self.id = id
    self.year = year
    self.roster_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{id}"
    self.players_url = "https://www70.myfantasyleague.com/#{year}/export?TYPE=players&DETAILS=&SINCE=&PLAYERS=&JSON=0"
    self.franchises_url = "https://www61.myfantasyleague.com/#{year}/export?TYPE=league&L=#{id}"
  end

  def import_contracts
    franchises = Franchise.all.to_a
    doc = Nokogiri::XML(open(roster_url))
    franchise_nodes = doc.xpath("//franchise")

    franchises.each do |f|
      f.league = self
      contract_nodes = doc.xpath("//franchise[@id=#{f.franchise_id}]/player")
      f.contracts = []
      contract_nodes.each do |p|
        f.contracts << Contract.new(player_id:              p["id"],
                                    contract_terms:         p["contractStatus"],
                                    roster_status:          p["status"],
                                    acquired_cost:          p["contractYear"].to_i,
                                    notes:                  p["contractInfo"],
                                    salary:                 p["salary"].to_i,
                                    franchise:              f)
      end
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
