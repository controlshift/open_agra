class AddRedirectAfterSignature < ActiveRecord::Migration
  def change
    add_column :petitions, :after_signature_redirect_url, :text
  end
end
