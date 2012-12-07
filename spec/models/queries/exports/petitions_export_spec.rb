require 'spec_helper'

describe Queries::Exports::PetitionsExport do
  context "instantiated" do
    subject { Queries::Exports::PetitionsExport.new  }

    it "should have signatures as a name" do
      subject.name.should == 'petitions'
    end
  end

  context "with a petition" do
    before(:each) do
      @organisation = Factory(:organisation)
      @petitions = []
      @petition_1 = Factory(:petition, organisation: @organisation)
      @petitions << @petition_1
    end

    subject { Queries::Exports::PetitionsExport.new(organisation: @organisation) }

    context "several petitions" do
      before(:each) do
        4.times do
          @petitions << Factory(:petition, organisation: @organisation)
        end
      end

      it "should successfully find in batches" do
        petitions = []
        count = 0
        subject.find_in_batches(batch_size: 2) do |batch|
          if count == 2
            batch.size.should == 1
          else
            batch.size.should == 2
          end
          batch.each do |petition|
            # prove that we only see each petition once.
            petitions.should_not include(petition['id'])
            petitions << petition['id']
          end
          count = count+1
        end
        petitions.size.should == 5
      end
    end

    it "should export petitions" do
      subject.as_csv_stream.to_s.should_not == ""
    end
  end
end