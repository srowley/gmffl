require 'rails_helper'

describe Contract do
  before(:each) do
    @league = League.new(42618, 2018)
    @franchise = Franchise.new(league: @league)
    @contract= Contract.new(franchise: @franchise)
    good_player = Player.create(player_id: 1)
    good_player_stats = Stat.create(player_id: 1, rank: 4, position: "QB")
    @contract.player_id = 1
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
        bad_player = Player.create(player_id: 2)
        bad_player_stats = Stat.create(player_id: 2, rank: 16, position: "QB")
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
  
  describe "#stats" do
    it "returns the score and rank for a given player" do
      expect(@contract.stats.rank).to eq(4)
      expect(@contract.stats.position).to eq("QB") 
    end
  end
end

