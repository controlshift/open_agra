require 'spec_helper'

describe Queries::Petitions::DetailQuery do
  it { should validate_presence_of :organisation }
  it { should validate_presence_of :search_term }
end