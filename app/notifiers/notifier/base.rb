module Notifier
  class Base
    include Notifier::Callbacks
    before_sign_up :ensure_category_pages_present, :ensure_external_petition_present, :ensure_creators_page_present

    attr_accessor :petition, :organisation, :user_details, :role

    def notify_sign_up(params)
      self.petition = params[:petition]
      self.organisation = params[:organisation]
      self.user_details = params[:user_details]
      self.role         = params[:role]

      run_callbacks :notify_sign_up do
        self.process_sign_up
      end
    end

    def params
      {petition: petition, user_details: user_details, organisation: organisation}
    end

  end
end