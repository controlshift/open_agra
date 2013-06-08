Agra::Application.configure do
  if ENV['SENDGRID_USERNAME'].present? && ENV['SENDGRID_PASSWORD'].present?
    ActionMailer::Base.smtp_settings = {
        address: "smtp.sendgrid.net",
        port: 587,
        authentication: :plain,
        enable_starttls_auto: true,
        openssl_verify_mode: 'none',
        domain: ENV['SENDGRID_DOMAIN'],
        user_name: ENV['SENDGRID_USERNAME'],
        password: ENV['SENDGRID_PASSWORD']
    }

    config.action_mailer.delivery_method = :smtp
  end
end
