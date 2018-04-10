require 'rails_helper'

describe Player do
  before(:each) do
    @league = League.new(year: 2018)
    @franchise = Franchise.new(league: @league)
    @player = Player.new(franchise: @franchise)
  end

  context "will have finished his second contract year" do
    before(:each) do
      @player.contract = "3L-2019"
    end

    describe "#holdout_eligible?" do
      it "returns true" do
        expect(@player.holdout_eligible?).to be true
      end
    end
  end

  context "is a rookie" do
    before(:each) do
      @player.contract = "3L-2020R"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@player.holdout_eligible?).to be false
      end
    end
  end

  context "on a grandfathered contract" do
    before(:each) do
      @player.contract = "3L-2019*"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@player.holdout_eligible?).to be false
      end
    end
  end

  context "on a holdout-eligible contract" do
    before(:each) do
      @player.contract = "3L-2020"
    end

    describe "#holdout_eligible?" do
      it "returns true" do
        expect(@player.holdout_eligible?).to be true
      end
    end
  end

  context "is on the last year of their contract " do
    before(:each) do
      @player.contract = "1L-2018"
    end

    describe "#holdout_eligible?" do
      it "returns false" do
        expect(@player.holdout_eligible?).to be false
      end
    end
  end

  context "with a locked contract" do

    before(:each) do
      @player.contract = "5L-2021"
      @player.acquired_cost = 34
      @player.salary = 34
    end

    describe "#dead_cap" do
      it "calculates dead cap correctly" do
        expect(@player.dead_cap).to eq(68)
      end

      it "returns zero if the player is on the taxi squad" do
        @player.roster_status = "TAXI_SQUAD"
        expect(@player.dead_cap).to eq(0)
      end
    end

    describe "#contract_type" do
      it "parses correctly" do
        expect(@player.contract_type).to eq("Locked")
      end
    end

    describe "#contract_end" do
      it "parses correctly" do
        expect(@player.contract_end).to eq(2021)
      end
    end

    describe "#salary_schedule" do
      it "returns a hash of salaries for each contract year" do
        expect(@player.salary_schedule).to include({ 2018 => 34, 2019 => 34, 2020 => 34, 2021 => 34 })
      end
    end
  end

  context "with a guaranteed contract" do

    before(:each) do
      @player.contract = "5G-2021"
      @player.salary =  34
    end

    describe "#dead_cap" do
      it "calculates dead cap correctly" do
        expect(@player.dead_cap).to eq(29)
      end

      it "returns zero if the player is on the taxi squad" do
        @player.roster_status = "TAXI_SQUAD"
        expect(@player.dead_cap).to eq(0)
      end
    end

    describe "#contract_type" do
      it "parses correctly" do
        expect(@player.contract_type).to eq("Guaranteed")
      end
    end

    describe "#contract_end" do
      it "parses correctly" do
        expect(@player.contract_end).to eq(2021)
      end
    end
   
    describe "#salary_schedule" do
      it "returns a hash of salaries for each contract year" do
        expect(@player.salary_schedule).to include({ 2018 => 34, 2019 => 36, 2020 => 38, 2021 => 40 })
      end
    end
  end
end

