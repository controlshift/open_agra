class EmailAndSubscriptionMustMatchValidator < ActiveModel::Validator
  def validate(record)
    if record.email && record.subscription
      if record.subscription.email.casecmp(record.email.to_s) != 0
        record.errors[:email] << I18n.t('errors.messages.email_subscription.dont_match')
      end
    end
  end
end

class GroupUnsubscribe
  include ActiveModel::Validations
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :subscription, :email

  validates_presence_of :subscription, :email
  validates :email, email_format: true
  validates_with EmailAndSubscriptionMustMatchValidator

  def initialize(attrs = {})
    attrs.each do |key,value|
      if self.respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end


  def unsubscribe
    if valid?
      # end the group subscription
      subscription.unsubscribe!

      # unsubscribe from all petitions in the group.
      subscription.group.petitions.each do | petition |
        signature = Signature.where(petition_id: petition.id, email: email).first
        if signature
          # it is okay if validations fail on child signatures. Just move on.
          unsubscribe = Unsubscribe.new(petition: petition, email: email, signature: signature )
          unsubscribe.unsubscribe
        end
      end
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