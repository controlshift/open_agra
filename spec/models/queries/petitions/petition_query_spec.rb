require 'spec_helper'

describe Queries::Petitions::PetitionQuery do
  subject { Queries::Petitions::PetitionQuery.new }

  it { should respond_to(:execute!)}
  it { should respond_to(:configuration)}
  it { should respond_to(:petitions)}
  it { should validate_numericality_of :page }

  context "an invalid query" do
    subject { Queries::Petitions::PetitionQuery.new page: 'foo' }

    it "should return nil if an invalid query" do
      subject.execute!.should be_nil
    end
  end
end