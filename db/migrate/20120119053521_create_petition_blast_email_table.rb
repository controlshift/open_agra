class CreatePetitionBlastEmailTable < ActiveRecord::Migration
  def up
    create_table :petition_blast_emails do |t|
      t.references :petition
      t.string :from_name, null: false
      t.string :from_address, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :delayed_job_id
      
      t.timestamps
    end
  end

  def down
    drop_table :petition_blast_emails
  end
end
