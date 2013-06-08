class NoUnsubFromOwnPetitionValidator < ActiveModel::Validator
  def validate(record)
    if (record.petition &&
        record.petition.user &&
        record.petition.email.casecmp(record.email.to_s) == 0)

      record.errors[:base] << I18n.t('errors.messages.petition.unsubscribe')
    end
  end
end
