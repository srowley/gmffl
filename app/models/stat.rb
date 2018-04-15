class Stat < ApplicationRecord

  belongs_to :player

  def self.import_week_xml(league, week)
    base_url = league.stats_base_url
    url = base_url + "W=#{week}"
    doc = Nokogiri::XML(open(url))
    rows = doc.xpath("//playerScore")
    stat_objects = []
    rows.each do |r|
      stat_objects << Stat.new(year: league.year,
                                  week: week,
                                  player_id: r["id"].to_i,
                                  score: r["score"].to_i)
    end
    Stat.import stat_objects
  end

  def self.import_xml(league)
    1..17.times { |w| Stat.import_week_xml(league, w + 1) }
  end
end
