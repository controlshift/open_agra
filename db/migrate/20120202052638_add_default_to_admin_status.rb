class AddDefaultToAdminStatus < ActiveRecord::Migration
  def up
    change_column :petitions, :admin_status, :string, default: 'unreviewed'
    Petition.all.each do | p |
      p.admin_status = 'unreviewed' if p.admin_status.blank?
    end
  end

  def down
    change_column :petitions, :admin_status, :string, default: nil
  end
end
