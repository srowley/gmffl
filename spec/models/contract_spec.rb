require 'rails_helper'

describe Contract do
  before(:each) do
    @league = League.new(42618, 2018)
    @franchise = Franchise.create(league: @league, franchise_id: "0001")
    @good_player = Player.create(position: "QB", player_id: 1)
    allow(@good_player).to receive(:holdout_rank).and_return(2)
    @contract = Contract.create(franchise: @franchise, player: @good_player)
  end

  describe "::import_xml" do
    it "imports MFL roster data" do
      #would be great to raise error on import fail due to validations
      @league.franchises_url = "#{Rails.root}/spec/fixtures/files/franchises.xml"
      Franchise.import_xml(@league)
      @league.players_url = "#{Rails.root}/spec/fixtures/files/players.xml"
      Player.import_xml(@league)
      @league.roster_url = "#{Rails.root}/spec/fixtures/files/rosters.xml"
      Contract.import_xml(@league)
      expect(Contract.count).to eq(233)
    end
  end

  context "is not extended" do
    before(:each) do
      @contract.contract_terms = "3L-2018"
    end

    describe "#extended" do
      it "returns false" do
        expect(@contract.extended?).to be false
      end
    end
  end

  context "is extended" do
    before(:each) do
      @contract.contract_terms = "3L-2018E"
    end

    describe "#extended" do
      it "returns true" do
        expect(@contract.extended?).to be true
      end
    end
  end

  context "will have finished his second contract year" do
    before(:each) do
      @contract.contract_terms = "3L-2019"
    end

    describe "#holdout_eligible?" do
      it "returns true" do
        expect(@contract.holdout_eligible?).to be true
      end
    end
  end

  context "is a rookie" do
    before(:each) do
      @contract.contract_terms = "3L-2020R"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@contract.holdout_eligible?).to be false
      end
    end
  end

  context "on a grandfathered contract" do
    before(:each) do
      @contract.contract_terms = "3L-2019*"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@contract.holdout_eligible?).to be false
      end
    end
  end

  context "on a holdout-eligible contract" do
    before(:each) do
      @contract.contract_terms = "3L-2020"
    end

    context "if met performance threshold last year" do
      describe "#holdout_eligible?" do
        it "returns true" do
          expect(@contract.holdout_eligible?).to be true
        end
      end
    end

    context "if did not meet performance threshold last year" do
      before(:each) do
        bad_player = Player.create(player_id: 2, position: "QB")
        allow(bad_player).to receive(:holdout_rank).and_return(30)
        @contract.player_id = 2
      end

      describe "#holdout_eligible?" do
        it "returns false" do
          expect(@contract.holdout_eligible?).to be false 
        end
      end
    end
  end

  context "is on the last year of their contract " do
    before(:each) do
      @contract.contract_terms = "1L-2018"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@contract.holdout_eligible?).to be false
      end
    end
  end

  context "with a locked contract" do

    before(:each) do
      @contract.contract_terms = "5L-2021"
      @contract.acquired_cost = 34
      @contract.salary = 34
    end

    describe "#dead_cap" do
      it "calculates dead cap correctly" do
        expect(@contract.dead_cap).to eq(68)
      end

      it "returns zero if the player is on the taxi squad" do
        @contract.roster_status = "TAXI_SQUAD"
        expect(@contract.dead_cap).to eq(0)
      end

      it "incorporates adjustments correctly" do
        contract_terms = "6L-2020"
        acquired_cost = "34"
        notes = "2015: Grandfathered for contract extension; 2015: $27 advanced; 2016-2018 salary = 30, 2019-2020 salary = 29; 2017: 7 kept by Ephraim in trade; 2018: 8 kept by Ephraim in trade; 2019: 9 kept by Ephraim in trade; 2020: 10 kept by Ephraim in trade; 2018 (FUTURE DCH): $5 kept by Darren in trade [Advanced:2015:27;Transferred:2017:7;Transferred:2018:8;Transferred:2019:9;Transferred:2020:10;Transferred:2018:5]"
        @contract = Contract.create(franchise: @franchise, player: @player, notes: notes, acquired_cost: acquired_cost, contract_terms: contract_terms)
        expect(@contract.dead_cap).to eq(27)
      end
    end

    describe "#type" do
      it "parses correctly" do
        expect(@contract.type).to eq("Locked")
      end
    end

    describe "#start_year" do
      it "parses correctly" do
        expect(@contract.start_year).to eq(2017)
      end
    end

    describe "#last_year" do
      it "parses correctly" do
        expect(@contract.last_year).to eq(2021)
      end
    end

    describe "#salary_schedule" do
      it "returns a hash of salaries for each contract year" do
        expect(@contract.salary_schedule).to include({ 2018 => 34, 2019 => 34, 2020 => 34, 2021 => 34 })
      end
    end
  end

  context "with a guaranteed contract" do

    before(:each) do
      @contract.contract_terms = "5G-2021"
      @contract.acquired_cost = 32
      @contract.salary =  34
    end

    describe "#guaranteed?" do
      it "returns true" do
        expect(@contract.guaranteed?).to be true
      end
    end

    describe "#dead_cap" do
      it "calculates dead cap correctly" do
        expect(@contract.dead_cap).to eq(21)
      end

      it "returns zero if the player is on the taxi squad" do
        @contract.roster_status = "TAXI_SQUAD"
        expect(@contract.dead_cap).to eq(0)
      end
    end

    describe "#type" do
      it "parses correctly" do
        expect(@contract.type).to eq("Guaranteed")
      end
    end

    describe "#start_year" do
      it "parses correctly" do
        expect(@contract.start_year).to eq(2017)
      end
    end

    describe "#last_year" do
      it "parses correctly" do
        expect(@contract.last_year).to eq(2021)
      end
    end
   
    describe "#salary_schedule" do
      it "returns a hash of salaries for each contract year" do
        expect(@contract.salary_schedule).to include({ 2018 => 34, 2019 => 36, 2020 => 38, 2021 => 40 })
      end
    end
  end

  context "with a simple contract" do
    describe "#events" do
      it "is empty" do
        expect(@contract.events).to be_empty
      end
    end
  end

  context "with a complicated contract" do
    before(:each) do
      notes = "2017: $8 deferred; 2018 contract = $27 [Deferred:2017:8;Advanced:2016:10]"
      @complicated_contract = Contract.create(franchise: @franchise, player: @good_player, notes: notes)
    end
   
    describe "#events" do
      it "has two elements" do
        expect(@complicated_contract.events.length).to eq(2)
      end

      it "has a properly populated event object" do
        expect(@complicated_contract.events[0].type).to eq("Deferred")
        expect(@complicated_contract.events[1].type).to eq("Advanced")
      end
    end
  end
end
