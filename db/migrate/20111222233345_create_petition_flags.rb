class CreatePetitionFlags < ActiveRecord::Migration
  def change
    create_table :petition_flags do |t|
      t.integer :petition_id
      t.integer :user_id
      t.string  :ip_address

      t.timestamps
    end
    
    add_index :petition_flags, :petition_id
    add_index :petition_flags, :user_id
    add_index :petition_flags, :ip_address
  end
end
