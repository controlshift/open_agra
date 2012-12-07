class PostalCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.country.present?
      case record.country
        when 'US'
          record.errors[attribute] << (options[:message] || 'is not a valid zip code') unless value.present? && GoingPostal.postcode?(value, 'US')
        when 'GB', 'AU'
          record.errors[attribute] << (options[:message] || 'is not a valid postal code') unless value.present? && GoingPostal.postcode?(value, record.country)
        when 'IN'
          # do nothing
        else
          record.errors[attribute] << (options[:message] || 'a postal code is required') unless value.present?
      end
    end
  end
end