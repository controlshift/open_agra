class AddFeedbackInformationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :campaigner_feedback_link, :string
    add_column :organisations, :user_feedback_link, :string
  end
end
