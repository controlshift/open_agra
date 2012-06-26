class AddPostcodeColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, "postcode", :string
  end
end
