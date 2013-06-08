module Adapters
  module ActionKit
    module ActionFields
      module Fake
        def self.custom_fields(member)
          {action_custom: 'a custom field'}
        end
      end
    end
  end
end