require 'rails_helper'

describe Stat do
 before(:each) do
   @player = Player.create(player_id: 1)
   @stat = Stat.new(score: 54, rank: 4, player: @player)
 end

 describe "#player" do
   it "returns the player id" do
    expect(@stat.player.player_id).to eq(1)
   end
 end
end
