class PetitionAndSignatureMustMatchValidator < ActiveModel::Validator
  def validate(record)
    if record.petition && record.signature
      if record.petition != record.signature.petition
        record.errors[:base] << "The signature and the petition must match"
      end

      if record.signature.email.casecmp(record.email.to_s) != 0
        record.errors[:email] << "does not match."
      end
    end
  end
end