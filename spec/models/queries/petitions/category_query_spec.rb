require 'spec_helper'

describe Queries::Petitions::CategoryQuery do
  it { should validate_presence_of :organisation }

  # more tests for this class is in the file spec/external/queries/category_query_spec.rb
end
