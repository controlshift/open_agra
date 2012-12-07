class AddAdditionalFieldsToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :additional_fields, :hstore
  end
end
