class TargetCollection < ActiveRecord::Base
  belongs_to :organisation
  has_many :targets

  validates :organisation, presence: true
  validates :name, presence: true, uniqueness: {scope: :organisation_id}
end