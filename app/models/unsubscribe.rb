class NoUnsubFromOwnPetitionValidator < ActiveModel::Validator
  def validate(record)
    if (record.petition &&
        record.petition.user &&
        record.petition.email.casecmp(record.email.to_s) == 0)

      record.errors[:base] << "You can not unsubscribe from your own campaign."
    end
  end
end

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

class Unsubscribe
  include ActiveModel::Validations
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :petition, :signature, :email

  validates_with NoUnsubFromOwnPetitionValidator
  validates_with PetitionAndSignatureMustMatchValidator

  validates_presence_of :signature, :petition, :email
  validates :email, email_format: true

  def initialize(attrs = {})
    attrs.each do |key,value|
      if self.respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end


  def unsubscribe
    if valid?
      @signature.unsubscribe_at = Time.now.utc
      SignaturesService.new.save(@signature)
    else
      nil
    end
  end


  def persisted?
    false
  end

  def self.reflect_on_association(association)
    nil
  end
end