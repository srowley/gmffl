require 'rails_helper'

describe Event do
  before(:each) do
    @league = League.new(42618, 2018)
    @franchise = Franchise.create(league: @league, franchise_id: "0001")
    @player = Player.create(position: "QB", player_id: 1)
  end

  describe "#adjustment_schedule" do
    context "with a deferral" do
      before(:each) do
        notes = "2017: $8 deferred; 2018 contract = $27 [Deferred:2017:8]"
        contract = Contract.create(contract_terms: "5G-2021", franchise: @franchise, player: @player, notes: notes)
        @event = contract.events[0]
      end

      it "provides a hash of adjustments" do
        expect(@event.adjustment_schedule).to eq({ 2018 => 10 })
      end
    end

    context "with an advance" do
      before(:each) do
        notes = "2017: $13 advanced; [Advanced:2017:13]"
        contract = Contract.create(contract_terms: "4L-2021", franchise: @franchise, player: @player, notes: notes)
        @event = contract.events[0]
      end

      it "provides a hash of adjustments" do
        expect(@event.adjustment_schedule).to eq({ 2018 => -3, 2019 => -3, 2020 => -3, 2021 => -4 })
      end
    end

    context "with a transfer" do
      before(:each) do
        notes = "2017: $10 held by Darren in 2020 [Transferred:2020:10]"
        contract = Contract.create(contract_terms: "4L-2021", franchise: @franchise, player: @player, notes: notes)
        @event = contract.events[0]
      end

      it "provides a hash of adjustments" do
        expect(@event.adjustment_schedule).to eq({ 2020 => -10 })
      end
    end
  end 
end
