class ChangeModerationReasonDataTypeForPetitionBlastEmails < ActiveRecord::Migration
  def self.up
      change_table :petition_blast_emails do |t|
        t.change :moderation_reason, :text
      end
    end

    def self.down
      change_table :petition_blast_emails do |t|
        t.change :moderation_reason, :string
      end
    end
end
