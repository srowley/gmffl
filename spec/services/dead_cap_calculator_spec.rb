require 'rails_helper'

describe DeadCapCalculator do
  before(:each) do
    @league = League.new(46218, 2018)
    @franchise = Franchise.create(franchise_id: "0001", league: @league)
    @player = Player.create(player_id: 1)
    @contract = Contract.create(franchise: @franchise, player: @player)
  end

  describe "#call" do

    context "when player is on the taxi squad" do
      it "returns zero" do
        @contract.contract_terms = "5G-2021"
        @contract.acquired_cost = 32
        @contract.roster_status = "TAXI_SQUAD"
        expect(DeadCapCalculator.new(@contract).call).to eq(0)
      end
    end

    context "Dez Bryant" do
      it "returns the correct dead cap hit" do
        contract_terms = "6L-2020"
        acquired_cost = "34"
        notes = "2015: Grandfathered for contract extension; 2015: $27 advanced; 2016-2018 salary = 30, 2019-2020 salary = 29; 2017: 7 kept by Ephraim in trade; 2018: 8 kept by Ephraim in trade; 2019: 9 kept by Ephraim in trade; 2020: 10 kept by Ephraim in trade; 2018 (FUTURE DCH): $5 kept by Darren in trade [Advanced:2015:27;Transferred:2017:7;Transferred:2018:8;Transferred:2019:9;Transferred:2020:10;Transferred:2018:5]" 
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(27)
      end
    end

    context "Tom Brady" do
      it "returns the correct dead cap hit" do
        contract_terms = "3L-2018E"
        acquired_cost = "27"
        notes = "2016: Extended @$27 through 2018; 2016: advanced $20, 2017-2018 salary = $17; 2017: $4 deferred; 2018: $5 deferral penalty [Advanced:2016:20;Deferred:2017:4;Extended:2016:2G-2016]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(14)
      end
    end

    context "Carlos Hyde" do
      it "returns the correct dead cap hit" do
        contract_terms = "6L-2019*R"
        acquired_cost = "20"
        notes = "2018-2019: 5 kept by Ephraim in trade; 2017: $4 deferred; 2018: $5 deferral penalty [Transferred:2018:5;Transferred:2019:5;Deferred:2017:4]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(21)
      end
    end

    context "Isaiah Crowell" do
      it "returns the correct dead cap hit" do
        contract_terms = "6G-2019*"
        acquired_cost = "1"
        @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(3)
      end
    end

    context "Larry Fitzgerald" do
      it "returns the correct dead cap hit" do
        contract_terms = "3L-2018E"
        acquired_cost = "3"
        notes = "2016: Extended from 2G-2016 ($3 initial) to 3L-2018 ($4/yr); 2017: Stashed; 2018: HOLDING OUT ($34) [Extended:2016:2G-2016]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
      end
    end

    context "Eli Manning" do
      it "returns the correct dead cap hit" do
        contract_terms = "3L-2018E"
        acquired_cost = "39"
        notes = "2016: Extended from 2G-2016 ($39 initial) to 3L-2018 (2017 2018 salary = $41); 2018: $21 to be kept by Aaron in trade [Extended:2016:2G-2016;Transferred:2018:21]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(10)
      end
    end

    context "Jordy Nelson" do
      it "returns the correct dead cap hit" do
        contract_terms = "4G-2018"
        acquired_cost = "2"
        @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(DeadCapCalculator.new(@contract).call).to eq(2)
      end
    end
  end
end
