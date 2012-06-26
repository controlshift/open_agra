class AddAdminStatusColumnToPetition < ActiveRecord::Migration
  def up
    add_column :petitions, :admin_status, :string
    
    Petition.all.each do |p|
      p.admin_status = :unreviewed
      p.save!
    end
    
    add_index :petitions, :admin_status
  end
  
  def down
    remove_column :petitions, :admin_status
  end
end
