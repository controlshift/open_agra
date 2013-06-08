class AddSourceToPetitions < ActiveRecord::Migration
  def change
    add_column :signatures, :source, :string, default: ''
    add_index  :signatures, :source
  end
end
