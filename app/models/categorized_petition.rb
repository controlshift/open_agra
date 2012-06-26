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

class CategorizedPetition < ActiveRecord::Base
  belongs_to :category
  belongs_to :petition, touch: true

  validates :category_id, uniqueness: { :scope => :petition_id }

  after_save -> { petition.reload; petition.solr_index }
  after_destroy -> { petition.reload; petition.solr_index }
end
