module Notifiers
  module Salesforce
    module Rspec
      def self.custom_fields(member)
        {'Data_Source__c' => 'ControlShift'}
      end
    end
  end
end