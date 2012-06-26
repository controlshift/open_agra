# == Schema Information
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  query       :string(255)
#  latitude    :decimal(13, 10)
#  longitude   :decimal(13, 10)
#  street      :string(255)
#  locality    :string(255)
#  postal_code :string(255)
#  country     :string(255)
#  region      :string(255)
#  warning     :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  extras      :text
#

require 'spec_helper'

describe Location do
  it { should validate_presence_of(:query) }
  it { should validate_presence_of(:latitude) }
  it { should validate_presence_of(:longitude) }

  context "with a location" do
    subject { Factory(:location) }
    it { should validate_uniqueness_of(:query) }
  end
end
