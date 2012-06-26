class CreateEfforts < ActiveRecord::Migration
  def change
    create_table :efforts do |t|
      t.integer :organisation_id
      t.string :title
      t.string :slug
      t.text :description
      t.text :gutter_text
      [:title, :who, :what, :why].each do | petition_field |
        t.string "#{petition_field}_help"
        t.string "#{petition_field}_label"
        t.text   "#{petition_field}_default"
      end
      t.timestamps
    end

    add_column :petitions, :effort_id, :integer

    add_index :petitions, :effort_id
    add_index :efforts, :organisation_id
    add_index :efforts, :slug

    rename_column :petitions, :what_want, :what
    rename_column :petitions, :who_petitioning, :who
    rename_column :petitions, :why_important, :why
  end
end
