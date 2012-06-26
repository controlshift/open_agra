class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string  :title
      t.text    :content
      t.boolean :featured

      t.timestamps
    end
  end
end
