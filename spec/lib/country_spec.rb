require 'spec_helper'

describe Country do
  it "should return nil when not found" do
    Country.find_by(:iso, "foobar").should be_nil
  end

  it "should return GB" do
    Country.find_by(:iso, "GB")[:printable_name].should == 'United Kingdom'
  end
end