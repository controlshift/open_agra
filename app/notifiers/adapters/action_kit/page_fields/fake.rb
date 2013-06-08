module Adapters
  module ActionKit
    module PageFields
      module Fake
        def self.custom_fields(petition)
          {list: '10'}
        end
      end
    end
  end
end