class CreateMembers < ActiveRecord::Migration
  def up
    create_table :members do |t|
      t.string :email
      t.integer :organisation_id
      t.timestamps
    end

    add_column :signatures, :member_id, :integer
    add_column :users, :member_id, :integer

    add_index :signatures, :member_id
    add_index :users, :member_id

    execute "CREATE UNIQUE INDEX lower_case_members_email ON members (lower(email), organisation_id);"

    migrate_users_and_signatures!
  end

  def down
    drop_table :members
    remove_column :signatures, :member_id
    remove_column :users, :member_id
  end

  def migrate_users_and_signatures!
    #User.find_each do |user|
    #  member = Member.lookup(user.email, user.organisation)
    #  if member.blank?
    #    member = Member.create(email: user.email, organisation: user.organisation)
    #  end
    #  user.member = member
    #  user.save
    #end
    #
    #Signature.find_each do |signature|
    #  member = Member.lookup(signature.email, signature.petition.organisation)
    #  if member.blank?
    #    member = Member.create(email: signature.email, organisation: signature.petition.organisation)
    #  end
    #  signature.member = member
    #  signature.save
    #end

  end
end
