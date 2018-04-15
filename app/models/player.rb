class Player < ApplicationRecord

  self.primary_key = "player_id"
  has_one :contract
  has_many :stats

  def self.import_xml(league)
    Player.delete_all
    doc = Nokogiri::XML(open(league.players_url))
    player_objects = []
    player_nodes = doc.xpath("//player")
    player_nodes.each do |p|
      player_objects << Player.new(player_id: p["id"], name: p["name"], position: p["position"]) if ["QB", "RB", "WR", "TE"].include? p["position"]
    end
    Player.import player_objects
  end

  def holdout_score(year)
   stats.where(year: year, week: [1..16]).map { |s| s.score }.sum
  end
  
  def self.ranks(year, position)
    Stat.where(year: year, week: [1..16]).joins(:player).where("players.position = ?", position).group(:player_id).sum(:score).sort_by{|k,v| v}.reverse
  end

  def holdout_rank(year)
    #need to handle when this returns nil because player didn't play last year
    ranks = Player.ranks(year, position)
    return 9999 unless ranks.flatten.include?(player_id)
    ranks.index {|s| s[0] == player_id} + 1
  end
end
