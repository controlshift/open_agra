class CreateEmailWhiteLists < ActiveRecord::Migration
  def change
    create_table :email_white_lists do |t|
      t.string :email

      t.timestamps
    end
  end
end
