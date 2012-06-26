class ExistingEmailsShouldBeApproved < ActiveRecord::Migration
  def up
    PetitionBlastEmail.all.each do |e|
      e.moderation_status = 'approved'
      e.save
    end
  end

  def down
  end
end
