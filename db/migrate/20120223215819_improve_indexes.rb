class ImproveIndexes < ActiveRecord::Migration
  def up
    remove_index :signatures, :petition_id
    remove_index :petitions, :admin_status
    remove_index :petitions, :slug
    remove_index :organisations, :host

    add_index :petition_blast_emails, [:petition_id, :created_at]
    add_index :petitions, :user_id
    add_index :organisations, :slug, :unique => true
    add_index :organisations, :host, :unique => true
    add_index :email_white_lists, :email
    add_index :petitions, :slug, :unique => true
    add_index :signatures, [:petition_id, :deleted_at, :unsubscribe_at], :name => "visible_petitions"
    add_index :petitions, [:organisation_id, :admin_status, :launched, :cancelled, :user_id, :updated_at], :order => {:updated_at => :desc}, :name => 'homepage_optimization'
  end

  def down
    remove_index :signatures,  :name => "visible_petitions"
    remove_index :petitions,  :name => 'homepage_optimization'
    remove_index :petitions, :slug
    remove_index :organisations, :slug
    remove_index :organisations, :host
    remove_index :email_white_lists, :email
    remove_index :petitions, :user_id
    remove_index :petition_blast_emails, [:petition_id, :created_at]



    add_index :organisations, :host
    add_index :petitions, :slug
    add_index :petitions, :admin_status
    add_index :signatures, :petition_id
  end
end
