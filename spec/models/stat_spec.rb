require 'rails_helper'

describe Stat do

 before(:each) do
   @stat = Stat.new(score: 54, rank: 4, player_id: 1)
 end

 describe "#player" do
   it "returns the player id" do
    expect(@stat.player).to eq(1)
   end
 end
end
