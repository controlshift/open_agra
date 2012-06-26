class AddUservoiceWidgetLinkToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :uservoice_widget_link, :string
  end
end
