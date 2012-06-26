require 'active_model'
require 'ostruct'

class OrgQueryResult
  include Enumerable

  attr_reader :fields

  def initialize(fields, values)
    @fields = fields
    @values = values
  end

  def each_row &block
    @values.each { |row_values| block.call(Row.new(@fields, row_values)) }
  end

  alias_method :each, :each_row

  def empty?
    @values.empty?
  end

  class Row < OpenStruct
    extend ActiveModel::Naming

    def initialize(fields, row)
      hash = {}
      fields.each_with_index { |field, index| hash[field.to_sym] = row[index] }
      super hash
    end
  end
end