require 'spec_helper'

class DummyRecord
  attr_accessor :errors
  
  def initialize
    @errors = { email: [] }
  end
end

describe EmailFormatValidator do
  let(:validator) { EmailFormatValidator.new({ attributes: [:email] }) }
  let(:record) { DummyRecord.new }
  
  it "should accept valid email address" do
    validator.validate_each(record, :email, "nathan.woody_1@gnail.con")
    record.errors[:email].should be_empty
  end
  
  '+_-.'.each_char do |sym|
    it "should accept email address with #{sym}" do
      validator.validate_each(record, :email, "nathan#{sym}woody@gnail.con")
      record.errors[:email].should be_empty
    end
  end
  
  '`~!@#$%^&*()={}[]|\:;<>,?/"'.each_char do |sym|
    it "should reject email address with #{sym}" do
      validator.validate_each(record, :email, "nathan#{sym}woody@gnail.con")
      record.errors[:email].should_not be_empty
    end
  end
end