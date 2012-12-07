module Extensions
  module Signature
    # an example extension for spec purposes
    module Rspec
      extend ActiveSupport::Concern

      included do
        additional_field :magician, { as: :boolean, label: 'Are you a magician?' }
      end
    end
  end
end
