class AddIndexSlugToTargets < ActiveRecord::Migration
  def change
    add_index :targets, :slug, name: 'target_slug'
  end
end
