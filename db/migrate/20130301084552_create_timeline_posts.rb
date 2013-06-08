class CreateTimelinePosts < ActiveRecord::Migration
  def change
    create_table :timeline_posts do |t|
      t.string :text
      t.integer :user_id
      t.integer :petition_id
      t.timestamps
    end

    add_index :timeline_posts, :user_id
    add_index :timeline_posts, :petition_id
  end
end
