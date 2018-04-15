class Stat < ApplicationRecord

  belongs_to :player

  def self.import(league)
    ["QB", "RB", "WR", "TE"].each do |position|
      url = "http://www61.myfantasyleague.com/#{league.year}/top?L=#{league.id}&SEARCHTYPE=BASIC&COUNT=100&YEAR=#{league.year-1}" +
             "&START_WEEK=1&END_WEEK=16&CATEGORY=overall&POSITION=#{position}&DISPLAY=points&TEAM=*"
      doc = Nokogiri::HTML(open(url))
      rows = doc.xpath("//div[@id='withmenus']//table/tbody/tr")
      stats = {}
    
      rows.each do |r|
        param_string = r.at_xpath("td[@class='points tot']/a/@href")
        param_string = /P=\d+/.match(param_string)
        stats[:year] = league.year
        stats[:player_id] = param_string.to_s[/\d+/].to_i
        stats[:position] = position
        stats[:rank] = r.at_xpath("td[@class='rank'][1]").text.chomp(".").to_i unless stats[:player_id] == 0
        stats[:score] = r.at_xpath("td[@class='points tot']/a/text()").to_s.to_i
        create(stats) unless stats[:player_id] == 0
      end
    end
  end
  
end
