require 'rails_helper'

feature "Roster Management", type: :feature do
  scenario "User views league rosters" do
    visit "/?league=42618&year=2018"
    expect(page).to have_text("Franchise 0001")
    expect(page).to have_css("td", text: "10695")
    expect(page).to have_css("td", text: "Active Roster")
    expect(page).to have_css("td", text: "Taxi Squad")
    expect(page).to have_css("td", text: "98")
    expect(page).to have_css("td", text: "210")
  end
end
