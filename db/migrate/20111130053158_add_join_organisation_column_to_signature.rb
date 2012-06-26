class AddJoinOrganisationColumnToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, 'join_organisation', :boolean
  end
end
