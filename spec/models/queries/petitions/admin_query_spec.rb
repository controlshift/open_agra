require 'spec_helper'

describe Queries::Petitions::AdminQuery do
  context "an initialized object" do
    subject { Queries::Petitions::AdminQuery.new }
    it { should validate_presence_of(:search_term) }
  end

  describe "initialization" do
    subject { Queries::Petitions::AdminQuery.new search_term: 'foo' }

    specify{ subject.search_term.should == 'foo'}

    it "should be valid" do
      subject.valid?.should be_true
    end
  end

  describe "initialization with an Organisation" do
    before(:each) do
      @org =  Organisation.new
      @petition_search = Queries::Petitions::AdminQuery.new search_term: 'foo', organisation: @org
    end

    specify{ @petition_search.search_term.should == 'foo'}
    specify{ @petition_search.organisation.should == @org}

    it "should be valid" do
      @petition_search.valid?.should be_true
    end
  end


end
