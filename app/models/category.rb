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
#

class Category < ActiveRecord::Base
  include HasSlug

  attr_accessible :name, :external_id

  validates :name, presence: :true, length: { maximum: 50 }, uniqueness: {scope: :organisation_id, case_sensitive: false}
  
  belongs_to :organisation
  has_many :categorized_petitions, dependent: :delete_all
  has_many :petitions, through: :categorized_petitions

  strip_attributes only: [:name]
  
  scope :active, ->(organisation_id){ where(organisation_id: organisation_id).order('name') }
end
