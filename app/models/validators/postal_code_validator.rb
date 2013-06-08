class PostalCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.country.present?
      case record.country
        when 'US'
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.postcode.zip')) unless value.present? && GoingPostal.postcode?(value, 'US')
        when 'GB', 'AU'
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.postcode.postal')) unless value.present? && GoingPostal.postcode?(value, record.country)
        when 'IN'
          # do nothing
        else
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.postcode.blank')) unless value.present?
      end
    end
  end
end