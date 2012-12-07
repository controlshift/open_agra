require 'spec_helper'

describe Queries::Petitions::List do
  before :each do
    @organisation = FactoryGirl.create(:organisation)
  end

  context "an initialized object" do
    subject { Queries::Petitions::List.new }

    it { should validate_presence_of(:sort_column) }
    it { should validate_presence_of(:sort_direction) }

    it { should_not allow_value('foo').for(:sort_column) }
    it { should_not allow_value('foo').for(:sort_direction) }

    ['asc', 'desc'].each do |direction|
      it { should allow_value(direction).for(:sort_direction) }
    end

    it "should set defaults" do
      subject.sort_direction.should == 'desc'
      subject.sort_column.should == 'created_at'
    end

  end

  describe "list" do
    it "all launched petitions" do
      launched_petition = FactoryGirl.create(:petition, organisation: @organisation, launched: true)
      awaiting_petition = FactoryGirl.create(:petition, organisation: @organisation, launched: false)

      pl = Queries::Petitions::List.new
      pl.petitions.count.should == 1
      pl.petitions.first.should == launched_petition
    end
  end

  describe "sort and paginate" do
    before :each do
      @user = FactoryGirl.create(:user, organisation: @organisation)
      @petition1 = FactoryGirl.create(:petition_without_leader, organisation: @organisation, title: "BBB", created_at: Time.now - 1)
      @petition2 = FactoryGirl.create(:petition, organisation: @organisation, user: @user, title: "AAA", created_at: Time.now)
      @petition3 = FactoryGirl.create(:petition, organisation: @organisation, user: @user, title: "CCC", created_at: Time.now + 1)
    end

    it "should order and paginate petitions by default" do
      pl = Queries::Petitions::List.new
      pl.petitions[0].should == @petition3
      pl.petitions[1].should == @petition2
      pl.petitions[2].should == @petition1
    end

    it "should be able to customize order column and its directions" do
      pl = Queries::Petitions::List.new sort_column: 'title', sort_direction: 'asc'
      pl.petitions[0].should == @petition2
      pl.petitions[1].should == @petition1
      pl.petitions[2].should == @petition3
    end

    it "should keep as default if column or direction not found" do
      pl = Queries::Petitions::List.new sort_column: 'invalid_column', sort_direction: 'invalid_direction'
      pl.petitions[0].should == @petition3
      pl.petitions[1].should == @petition2
      pl.petitions[2].should == @petition1
    end

    it "should sort by signatures count" do
      2.times { FactoryGirl.create(:signature, petition: @petition1) }
      1.times { FactoryGirl.create(:signature, petition: @petition2) }

      pl = Queries::Petitions::List.new sort_column: 'signatures_count', sort_direction: 'desc'
      pl.petitions[0].should == @petition1
      pl.petitions[1].should == @petition2
      pl.petitions[2].should == @petition3
    end

    it "should sort by petition flags count" do
      2.times { FactoryGirl.create(:petition_flag, petition: @petition1, user: FactoryGirl.create(:user, organisation: @organisation)) }
      1.times { FactoryGirl.create(:petition_flag, petition: @petition2, user: FactoryGirl.create(:user, organisation: @organisation)) }

      pl = Queries::Petitions::List.new sort_column: 'petition_flags_count', sort_direction: 'desc'
      pl.petitions[0].should == @petition1
      pl.petitions[1].should == @petition2
      pl.petitions[2].should == @petition3
    end

    it "should filter by organisation" do
      @organisation2 = FactoryGirl.create(:organisation)
      @petition4 = FactoryGirl.create(:petition, :organisation => @organisation2)
      pl = Queries::Petitions::List.new conditions: {:organisation_id => @organisation2.id}
      pl.petitions.should include(@petition4)
      pl.petitions.should_not include(@petition1)
    end
  end
end

