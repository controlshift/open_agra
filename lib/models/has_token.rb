require 'active_support/concern'

module HasToken
  extend ActiveSupport::Concern

  included do
    after_create :generate_token!
  end

  module ClassMethods

  end

  module InstanceMethods
    private

    def token_key
      to_param
    end

    def token_field
      :token
    end

    def generate_token!
      update_attribute("#{token_field}".intern, Digest::SHA1.hexdigest("#{token_key}_#{Agra::Application.config.sha1_salt}"))
    end
  end
end