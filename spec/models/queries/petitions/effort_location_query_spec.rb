require 'spec_helper'

describe Queries::Petitions::EffortLocationQuery do
  it { should validate_presence_of :organisation }
  it { should validate_presence_of :effort }
  it { should validate_presence_of :latitude }
  it { should validate_numericality_of :latitude }
  it { should validate_presence_of :longitude }
  it { should validate_numericality_of :longitude }
end