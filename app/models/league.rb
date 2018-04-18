require 'open-uri'

class League
 include ActiveModel::Model

 attr_accessor :id, :roster_url, :franchises, :year, :players_url, :franchises_url, :adjustments_url, :stats_base_url

  def initialize(id = nil, year = nil)
    self.id = id
    self.year = year
#    self.roster_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=rosters&L=#{id}"
    self.roster_url = "#{Rails.root}/spec/fixtures/files/rosters_with_notes.xml"
    self.players_url = "https://www70.myfantasyleague.com/#{year}/export?TYPE=players&DETAILS=&SINCE=&PLAYERS=&JSON=0"
    self.franchises_url = "https://www61.myfantasyleague.com/#{year}/export?TYPE=league&L=#{id}"
    self.adjustments_url = "https://www61.myfantasyleague.com/#{year}/export?TYPE=salaryAdjustments&L=#{id}"
    self.stats_base_url = "http://www61.myfantasyleague.com/#{year}/export?TYPE=playerScores&L=#{id}&"
  end
end
