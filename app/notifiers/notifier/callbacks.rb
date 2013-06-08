module Notifier
  module Callbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :notify_sign_up, :terminator => "result == false"
    end

    module ClassMethods
      def before_sign_up(*args)
        args.each do |arg|
          set_callback :notify_sign_up, :before, arg, :if => "!halted"
        end
      end
    end
  end
end