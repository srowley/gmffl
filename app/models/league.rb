require 'open-uri'

class League
 include ActiveModel::Model

 attr_accessor :id, :roster_url, :franchises, :year, :players_url

  def initialize(id = nil, year = nil)
    self.id = id
    self.year = year
    self.roster_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{id}"
    self.players_url = "https://www70.myfantasyleague.com/#{year}/export?TYPE=players&DETAILS=&SINCE=&PLAYERS=&JSON=0"
  end

  def import_contracts
    @franchises = []
    doc = Nokogiri::XML(open(roster_url))
    franchise_nodes = doc.xpath("//franchise")
    franchise_nodes.each do |f|
      @franchises << Franchise.new(id: f["id"], league: self)
    end

    @franchises.each do |f|
      contract_nodes = doc.xpath("//franchise[@id=#{f.id}]/player")
      f.contracts= []
      contract_nodes.each do |p|
        f.contracts << Contract.new(player_id:            p["id"],
                                  contract_terms:      p["contractStatus"],
                                  roster_status: p["status"],
                                  acquired_cost: p["contractYear"].to_i,
                                  notes:         p["contractInfo"],
                                  salary:        p["salary"].to_i,
                                  franchise:     f)
      end
    end
  end
  
  def import_players
    Player.delete_all
    doc = Nokogiri::XML(open(players_url))
    player_nodes = doc.xpath("//player")
    player_nodes.each do |p| 
      Player.create(player_id: p["id"], name: p["name"]) if ["QB", "RB", "WR", "TE"].include? p["position"]
    end
  end
end
