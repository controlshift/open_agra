class ExistingEmailsShouldBeApproved < ActiveRecord::Migration
  def up
    execute "UPDATE petition_blast_emails SET moderation_status='approved'"
  end

  def down
  end
end
