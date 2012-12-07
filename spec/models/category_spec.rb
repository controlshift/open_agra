# == Schema Information
#
# Table name: categories
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  organisation_id :integer
#  slug            :string(255)
#  external_id     :string(255)
#

require 'spec_helper'

describe Category do
  it { should validate_presence_of(:name) }
  
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:external_id) }
  
  it { should ensure_length_of(:name).is_at_most(50)}
  
  it { should belong_to(:organisation) }
  it { should have_many(:categorized_petitions) }
  it { should have_many(:petitions) }
  
  it 'should validate uniqueness of name' do
    Factory(:category)
    should validate_uniqueness_of(:name).scoped_to(:organisation_id).case_insensitive
  end

  describe '#strip_attributes' do
    let(:category) { Factory(:category, name: ' Fred') }

    it 'should strip attributes' do
      category.name.should == 'Fred'
    end
  end
end
