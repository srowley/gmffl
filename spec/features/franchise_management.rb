require 'rails_helper'

feature "Roster Management", type: :feature do
  before(:each) do
    league = League.new(42618, 2018)
    league.players_url = Rails.root.to_s + "/spec/fixtures/files/players.xml"
    league.import_players
  end

  scenario "User views league rosters" do
    visit "/?league=42618&year=2018"
    expect(page).to have_text("Franchise 0001")
    expect(page).to have_css("td", text: "Luck, Andrew")
    expect(page).to have_css("td", text: "Active Roster")
    expect(page).to have_css("td", text: "Taxi Squad")
    expect(page).to have_css("td", text: "104")
    expect(page).to have_css("td", text: "112")
  end
end
