class AddCommentsUpdatedAtToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :comments_updated_at, :datetime
  end
end
