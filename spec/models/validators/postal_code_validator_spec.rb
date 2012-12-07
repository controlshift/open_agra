require 'spec_helper'

class PostalDummyRecord
  attr_accessor :errors

  def initialize
    @errors = { code: [] }
  end
end

describe PostalCodeValidator do
  let(:validator) { PostalCodeValidator.new({ attributes: [:code] }) }
  let(:record) { PostalDummyRecord.new }

  context "in the US" do
    before(:each) do
      record.stub(:country).and_return('US')
    end

    it "should accept valid postal code" do
      validator.validate_each(record, :code, "02052")
      record.errors[:code].should be_empty
    end

    it "should not accept a blank" do
      validator.validate_each(record, :code, "")
      record.errors[:code].should_not be_empty
    end

    it "should not accept an invalid zipcode" do
      validator.validate_each(record, :code, "EC1A 1BB")
      record.errors[:code].should_not be_empty
    end
  end

  context "in India" do
    before(:each) do
      record.stub(:country).and_return('IN')
    end

    it "should accept any string" do
      validator.validate_each(record, :code, "foo")
      record.errors[:code].should be_empty
    end

    it "should accept a blank" do
      validator.validate_each(record, :code, "")
      record.errors[:code].should be_empty
    end

  end

  context "in GB" do
    before(:each) do
      record.stub(:country).and_return('GB')
    end

    it "should accept a valid code" do
      validator.validate_each(record, :code, "EC1A 1BB")
      record.errors[:code].should be_empty
    end

    it "should not accept a blank" do
      validator.validate_each(record, :code, "")
      record.errors[:code].should_not be_empty
    end

    it "should not accept an invalid code" do
      validator.validate_each(record, :code, "")
      record.errors[:code].should_not be_empty
    end
  end
end