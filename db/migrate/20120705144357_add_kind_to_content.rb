class AddKindToContent < ActiveRecord::Migration
  def change
    add_column :contents, :kind, :string, :default => 'text'
  end
end
