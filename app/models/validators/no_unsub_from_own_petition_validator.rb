class NoUnsubFromOwnPetitionValidator < ActiveModel::Validator
  def validate(record)
    if (record.petition &&
        record.petition.user &&
        record.petition.email.casecmp(record.email.to_s) == 0)

      record.errors[:base] << "You can not unsubscribe from your own campaign."
    end
  end
end
