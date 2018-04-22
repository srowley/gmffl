require 'rails_helper'

feature "Roster Management", type: :feature do
  before(:each) do
    league = League.new(42618, 2018)
    league.players_url = Rails.root.to_s + "/spec/fixtures/files/players.xml"
    league.franchises_url = Rails.root.to_s + "/spec/fixtures/files/franchises.xml"
    league.adjustments_url = Rails.root.to_s + "/spec/fixtures/files/adjustments.xml"
    Player.import_xml(league)
    Franchise.import_xml(league)
  end

  scenario "User views league rosters" do
    Capybara.reset_session!
    visit "/?league=42618&year=2018"
    expect(page).to have_text("Moonshiners")
    expect(page).to have_css("td", text: "Luck, Andrew")
    expect(page).to have_css("td", text: "Active Roster")
    expect(page).to have_css("td", text: "Taxi Squad")
    expect(page).to have_css("td", text: "104")
    expect(page).to have_css("td", text: "112")
    expect(page).to have_css("td", text: "87")
  end
end
