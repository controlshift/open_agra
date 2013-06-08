class CreateCsvReports < ActiveRecord::Migration
  def change
    create_table :csv_reports do |t|
      t.string :name
      t.integer :exported_by_id
      t.has_attached_file :report
			t.hstore :query_options
      t.timestamps
    end

    add_index :csv_reports, :exported_by_id
  end
end
