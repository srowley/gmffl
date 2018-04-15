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
    end

    describe "#contract_type" do
      it "parses correctly" do
        expect(@contract.contract_type).to eq("Locked")
      end
    end

    describe "#contract_end" do
      it "parses correctly" do
        expect(@contract.contract_end).to eq(2021)
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
      @contract.salary =  34
    end

    describe "#dead_cap" do
      it "calculates dead cap correctly" do
        expect(@contract.dead_cap).to eq(29)
      end

      it "returns zero if the player is on the taxi squad" do
        @contract.roster_status = "TAXI_SQUAD"
        expect(@contract.dead_cap).to eq(0)
      end
    end

    describe "#contract_type" do
      it "parses correctly" do
        expect(@contract.contract_type).to eq("Guaranteed")
      end
    end

    describe "#contract_end" do
      it "parses correctly" do
        expect(@contract.contract_end).to eq(2021)
      end
    end
   
    describe "#salary_schedule" do
      it "returns a hash of salaries for each contract year" do
        expect(@contract.salary_schedule).to include({ 2018 => 34, 2019 => 36, 2020 => 38, 2021 => 40 })
      end
    end
  end
end

