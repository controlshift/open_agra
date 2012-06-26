class AddPetitionTokenAndUserId < ActiveRecord::Migration
  def change
    add_column :petitions, 'token', :string
    add_column :petitions, 'user_id', :integer
  end
end
