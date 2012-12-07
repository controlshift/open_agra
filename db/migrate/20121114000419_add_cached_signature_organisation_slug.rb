class AddCachedSignatureOrganisationSlug < ActiveRecord::Migration
  def up
    add_column :signatures, :cached_organisation_slug, :string
    add_column :users,      :cached_organisation_slug, :string

    Organisation.all.each do |organisation|
      execute "UPDATE users SET cached_organisation_slug = '#{organisation.slug}' WHERE users.organisation_id = #{organisation.id}"
      organisation.petitions.each do | petition|
        execute "UPDATE signatures SET cached_organisation_slug = '#{organisation.slug}' WHERE signatures.petition_id = #{petition.id}"
      end
    end
  end

  def down
    remove_column :signatures, :cached_organisation_slug
    remove_column :users,      :cached_organisation_slug
  end
end
