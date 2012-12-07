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

class CategorizedEffort < ActiveRecord::Base
  belongs_to :category
  belongs_to :effort, touch: true

  validates :category_id, uniqueness: { :scope => :effort_id }
end
