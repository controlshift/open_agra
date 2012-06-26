# == Schema Information
#
# Table name: categorized_petitions
#
#  id          :integer         not null, primary key
#  category_id :integer
#  petition_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe CategorizedPetition do
  let(:petition) { mock_model(Petition) }
  let(:category) { mock_model(Category) }

  it { should belong_to :petition }
  it { should belong_to :category }

  it 'validates uniqueness of category' do
    CategorizedPetition.create(petition: Factory(:petition), category: Factory(:category))
    should validate_uniqueness_of(:category_id).scoped_to(:petition_id)
  end

  it 'should reindex and touch on saving' do
    petition.should_receive(:reload)
    petition.should_receive(:solr_index)
    petition.should_receive(:touch)
    cp = CategorizedPetition.new(petition: petition, category: category)
    cp.run_callbacks(:save)
  end

 it 'should reindex and touch on destroying' do
    petition.should_receive(:reload)
    petition.should_receive(:solr_index)
    petition.should_receive(:touch)
    cp = CategorizedPetition.new(petition: petition, category: category)
    cp.run_callbacks(:destroy)
  end

end
