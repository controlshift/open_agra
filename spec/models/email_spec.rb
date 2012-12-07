# == Schema Information
#
# Table name: emails
#
#  id           :integer         not null, primary key
#  to_address   :string(255)     not null
#  from_name    :string(255)     not null
#  from_address :string(255)     not null
#  subject      :string(255)     not null
#  content      :text            not null
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe Email do
  before(:each) do
    @email = Email.new
  end

  subject { @email }

  it { should validate_presence_of(:from_name) }
  it { should validate_presence_of(:from_address) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:to_address)}
  
  it { should ensure_length_of(:from_name).is_at_most(100) }
  it { should ensure_length_of(:subject).is_at_most(255) }
  it { should ensure_length_of(:content).is_at_most(1000) }
  
  it { should allow_mass_assignment_of(:from_name) }
  it { should allow_mass_assignment_of(:from_address) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:content) }
  
  it { should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:from_name) }
  it { should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:from_name) }
  it { should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:from_name) }

  it "should combine email with name" do
    subject.from_name = 'George'
    subject.from_address = 'g@washington.com'
    subject.email_with_name.should == '"George" <g@washington.com>'
  end
end
