class AddSpecializedIndexForTargetAutocompletion < ActiveRecord::Migration
  def up

    execute "CREATE INDEX name_autocomplete ON targets USING btree(lower(name) varchar_pattern_ops)"
  end

  def down
    execute "DROP INDEX name_autocomplete"
  end
end
