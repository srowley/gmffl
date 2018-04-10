require 'open-uri'

class League
 include ActiveModel::Model

 attr_accessor :id, :roster_url, :franchises, :year

  def initialize(id = nil, year = nil)
    self.id = id
    self.year = year
    self.roster_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{id}"
  end

  def import_rosters
    @franchises = []
    doc = Nokogiri::XML(open(roster_url))
    franchise_nodes = doc.xpath("//franchise")
    franchise_nodes.each do |f|
      @franchises << Franchise.new(id: f["id"], league: self)
    end

    @franchises.each do |f|
      player_nodes = doc.xpath("//franchise[@id=#{f.id}]/player")
      f.players = []
      player_nodes.each do |p|
        f.players << Player.new(id:            p["id"],
                                contract:      p["contractStatus"],
                                roster_status: p["status"],
                                acquired_cost: p["contractYear"].to_i,
                                notes:         p["contractInfo"],
                                salary:        p["salary"].to_i,
                                franchise:     f)
      end
    end
  end
end
