class RemoveTokenColumnFromPetition < ActiveRecord::Migration
  def up
    remove_column :petitions, :token
  end
  
  def down
    add_column :petitions, :token, :string
  end
end
