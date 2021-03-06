require 'rails_helper'

describe SalaryCalculator do
  before(:each) do
    @league = League.new(46218, 2018)
    @franchise = Franchise.create(franchise_id: "0001", league: @league)
    @player = Player.create(player_id: 1)
    @contract = Contract.create(franchise: @franchise, player: @player)
  end

  describe "#call" do

    context "with a guaranteed contract" do
      before(:each) do
        @contract_terms = "4G-2020R"
        @acquired_cost = 23
      end
    
      context "with no adjustments" do
        it "returns the correct salary schedule" do
          @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: @acquired_cost, contract_terms: @contract_terms)
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 23, 2018 => 25, 2019 => 27, 2020 => 29 })
        end
      end
      
      context "with a $4 deferral" do
        before(:each) do
          notes = "2017: $4 deferred; 2018: $5 deferral penalty [Deferred:2017:4]"
          @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: @acquired_cost, contract_terms: @contract_terms)
        end

        it "returns the correct salary schedule" do
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 19, 2018 => 30, 2019 => 27, 2020 => 29 })
        end
      end

      context "with a $6 transfer" do
        before(:each) do
          notes = " 2018: $6 held by Aaron [Transferred:2019:6]"
          @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: 23, contract_terms: "4G-2020R")
        end

        it "returns the correct salary schedule" do
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 23, 2018 => 25, 2019 => 21, 2020 => 29 })
        end
      end
    end

    context "with a locked contract" do
      before(:each) do
        @contract_terms = "5L-2021"
        @acquired_cost = 20
      end

      context "with no adjustments" do
        it "returns the correct salary schedule" do
          @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: @acquired_cost, contract_terms: @contract_terms)
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 20, 2018 => 20, 2019 => 20, 2020 => 20, 2021 => 20})
        end
      end

      context "with a $4 deferral" do
        before(:each) do
          notes = "2017: $4 deferred; 2018: $5 deferral penalty [Deferred:2017:4]"
          @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: @acquired_cost, contract_terms: @contract_terms)
        end

        it "returns the correct salary schedule" do
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 16, 2018 => 25, 2019 => 20, 2020 => 20, 2021 => 20 })
        end
      end

      context "with a $10 advance" do
        before(:each) do
          notes = "2017: $10 advanced; [Advanced:2017:10]"
          @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: @acquired_cost, contract_terms: @contract_terms)
        end

        it "returns the correct salary schedule" do
          expect(SalaryCalculator.new(@contract).call).to eq({ 2017 => 30, 2018 => 18, 2019 => 18, 2020 => 17, 2021 => 17 })
        end
      end
    end

    context "Dez Bryant" do
      it "returns the correct salary schedule" do
        contract_terms = "6L-2020"
        acquired_cost = "34"
        notes = "2015: Grandfathered for contract extension; 2015: $27 advanced; 2016-2018 salary = 30, 2019-2020 salary = 29; 2017: 7 kept by Ephraim in trade; 2018: 8 kept by Ephraim in trade; 2019: 9 kept by Ephraim in trade; 2020: 10 kept by Ephraim in trade; 2018 (FUTURE DCH): $5 kept by Darren in trade [Advanced:2015:27;Transferred:2017:7;Transferred:2018:8;Transferred:2019:9;Transferred:2020:10;Transferred:2018:5]" 
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2015 => 61, 2016 => 29, 2017 => 22, 2018 => 16, 2019 => 19, 2020 => 18 })
      end
    end

    context "Tom Brady" do
      it "returns the correct salary schedule" do
        contract_terms = "3L-2018E"
        acquired_cost = "27"
        notes = "2016: Extended @$27 through 2018; 2016: advanced $20, 2017-2018 salary = $17; 2017: $4 deferred; 2018: $5 deferral penalty [Advanced:2016:20;Deferred:2017:4;Extended:2016:2G-2016]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2015 => 25, 2016 => 47, 2017 => 13, 2018 => 22 })
      end
    end

    context "Carlos Hyde" do
      it "returns the correct salary schedule" do
        contract_terms = "6L-2019*R"
        acquired_cost = "20"
        notes = "2018-2019: 5 kept by Ephraim in trade; 2017: $4 deferred; 2018: $5 deferral penalty [Transferred:2018:5;Transferred:2019:5;Deferred:2017:4]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2014 => 20, 2015 => 20, 2016 => 20, 2017 => 16, 2018 => 20, 2019 => 15 })
      end
    end

    context "Isaiah Crowell" do
      it "returns the correct salary schedule" do
        contract_terms = "6G-2019*"
        acquired_cost = "1"
        @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2014 => 1, 2015 => 3, 2016 => 5, 2017 => 7, 2018 => 8, 2019 => 9 })
      end
    end

    context "Larry Fitzgerald" do
      it "returns the correct salary schedule" do
        contract_terms = "3L-2018E"
        acquired_cost = "3"
        notes = "2016: Extended from 2G-2016 ($3 initial) to 3L-2018 ($4/yr); 2017: Stashed; 2018: HOLDING OUT ($34) [Extended:2016:2G-2016]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2015 => 3, 2016 => 4, 2017 => 4, 2018 => 4 })
      end
    end

    context "Eli Manning" do
      it "returns the correct salary schedule" do
        contract_terms = "3L-2018E"
        acquired_cost = "39"
        notes = "2016: Extended from 2G-2016 ($39 initial) to 3L-2018 (2017 2018 salary = $41); 2018: $21 to be kept by Aaron in trade [Extended:2016:2G-2016;Transferred:2018:21]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2015 => 39, 2016 => 41, 2017 => 41, 2018 => 20 })
      end
    end

    context "Jordy Nelson" do
      it "returns the correct salary schedule" do
        contract_terms = "4G-2018"
        acquired_cost = "2"
        @contract = Contract.create(franchise: @franchise, player: @player, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(SalaryCalculator.new(@contract).call).to eq({ 2015 => 2, 2016 => 4, 2017 => 5, 2018 => 6})
      end
    end
  end
end
