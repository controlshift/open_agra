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