class AdditionalFieldValidator < ActiveModel::Validator
  def validate(record)
    if record.additional_field_configs.any?
      record.additional_field_configs.each do |field, config|
        if config[:validation_options].present?
          if config[:validation_options][:presence]
            validator = ActiveModel::Validations::PresenceValidator.new(attributes: [field])
            validator.validate(record)
          end
        end
      end
    end
  end
end