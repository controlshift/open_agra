class AddBsdConstituentGroupIdToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :bsd_constituent_group_id, :string
  end
end
