class AddReasonToPetitionFlag < ActiveRecord::Migration
  def change
    add_column :petition_flags, :reason, :text
  end
end
