class PetitionAndSignatureMustMatchValidator < ActiveModel::Validator
  def validate(record)
    if record.petition && record.signature
      if record.petition != record.signature.petition
        record.errors[:base] << I18n.t('errors.messages.petition_signature.doesnt_match')
      end

      if record.signature.email.casecmp(record.email.to_s) != 0
        record.errors[:email] << I18n.t('errors.messages.not_same')
      end
    end
  end
end