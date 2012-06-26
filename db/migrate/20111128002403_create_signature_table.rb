class CreateSignatureTable < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.references :petition
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :postcode
      t.timestamp :created_at
    end

    add_index :signatures, :petition_id
  end

end
