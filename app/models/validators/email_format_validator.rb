class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[A-Z0-9._+-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
      record.errors[attribute] << (options[:message] || 'is not a valid email')
    end
  end
end