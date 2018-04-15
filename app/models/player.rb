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
end
