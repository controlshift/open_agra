module Extensions
  module Signature
    # an example extension for spec purposes
    module Rspec
      extend ActiveSupport::Concern

      included do
        additional_field :magician, { as: :boolean, label: 'Are you a magician?' }
        additional_field :magician_kind, {as: :string, label: 'Kind of magician', validation_options: { presence: true} }
      end
    end
  end
end
