class CreateEmailsTable < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :to_address, null: false
      t.string :from_name, null: false
      t.string :from_address, null: false
      t.string :subject, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
