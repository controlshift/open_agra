# == Schema Information
#
# Table name: categorized_efforts
#
#  id          :integer         not null, primary key
#  category_id :integer
#  effort_id   :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe CategorizedEffort do
  let(:effort) { mock_model(Effort) }
  let(:category) { mock_model(Category) }

  it { should belong_to :effort }
  it { should belong_to :category }

  it 'validates uniqueness of category' do
    CategorizedEffort.create(effort: Factory(:effort), category: Factory(:category))
    should validate_uniqueness_of(:category_id).scoped_to(:effort_id)
  end
end
