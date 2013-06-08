module ActionMailer
  class Base
    def mail_with_set_organisation_host(options, &block)
      @organisation = options.delete(:organisation)

      if @organisation.nil?
        ActionMailer::Base.set_sendgrid_credential ENV['SENDGRID_USERNAME'], ENV['SENDGRID_PASSWORD']
      else
        ActionMailer::Base.set_sendgrid_credential @organisation.sendgrid_username, @organisation.sendgrid_password
      end

      mail_without_set_organisation_host options, &block
    end
    
    alias_method_chain :mail, :set_organisation_host

    private

    def self.set_sendgrid_credential(username, password)
      smtp_settings[:user_name] = username
      smtp_settings[:password] = password
    end
  end
end
