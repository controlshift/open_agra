require 'factory_girl'

namespace :db do
  desc "Fill database with sample data. You have to specify an organisation by host ORG_HOST=ahost."
  task :seed_fake_data => :environment do
    organisation = existing_organisation

    raise "Seems that seed_fake_data has already been done. Please rake db:reset_fake_data ORG_HOST=#{ENV['ORG_HOST']}" if Organisation.find_by_name("fake.org.#{organisation.name}")

    # the following user's emails are real gmail account
    admin = Factory(:admin, email: "agra.user.adm@gmail.com", organisation: organisation)
    org_admin = Factory(:org_admin, email: "agra.user.org@gmail.com", organisation: organisation)
    user_1 = Factory(:user, email: "agra.user.1@gmail.com", organisation: organisation)
    user_2 = Factory(:user, email: "agra.user.2@gmail.com", organisation: organisation)

    Factory(:petition, user: admin, organisation: organisation)
    Factory(:petition, user: org_admin, organisation: organisation)

    [10, 50, 101].each do |num_of_signatures|
      petition = Factory(:petition, user: user_1, organisation: organisation)
      num_of_signatures.times { Factory(:signature, petition: petition) }
    end

    11.times do
      petition = Factory(:petition, user: user_1, organisation: organisation)
      (rand(5)+rand(5)+1).times { Factory(:petition_flag, petition: petition, user: nil) }
      Factory(:petition_flag, user: user_2, petition: petition)
    end

    # creation of the fake organisation
    fake_organisation = Factory(:organisation, name: "fake.org.#{organisation.name}")
    10.times { Factory(:petition, organisation: fake_organisation, user: Factory(:user, organisation: fake_organisation)) }
    20.times { Factory(:user, organisation: fake_organisation) }
  end

  desc "Reset the fake data.You have specify a specific organisation by host ORG_HOST=ahost."
  task :reset_fake_data => :environment do
    organisation = existing_organisation

    delete_user_and_dependencies("agra.user.adm@gmail.com", organisation)
    delete_user_and_dependencies("agra.user.org@gmail.com", organisation)
    delete_user_and_dependencies("agra.user.1@gmail.com", organisation)
    delete_user_and_dependencies("agra.user.2@gmail.com", organisation)

    # delete everything under fake organisation
    fake_org_id = Organisation.where("name = ?", "fake.org.#{organisation.name}").first.id unless Organisation.where("name = ?", "fake.org.#{organisation.name}").first.nil?

    Petition.where("organisation_id = ?", fake_org_id).all.each do |petition|
      PetitionFlag.delete_all(["petition_id = ?", petition.id])
      Signature.delete_all(["petition_id = ?", petition.id])
      petition.delete
    end

    User.delete_all(["organisation_id = ?", fake_org_id])

    Organisation.delete(fake_org_id)
  end

  private

  def existing_organisation
    raise "You should specify an existing organisation by ORG_HOST=hostname." if ENV["ORG_HOST"].nil?

    if Organisation.find_by_host(ENV["ORG_HOST"])
      organisation = Organisation.find_by_host(ENV["ORG_HOST"])
    else
      raise "Organisation #{ENV["ORG_HOST"]} does not exist"
    end
    organisation
  end

  def delete_user_and_dependencies(email, organisation)
    user = User.where("email = ? and organisation_id = ?", email, organisation.id).first
    if user
      user.petitions.each do |petition|
        PetitionFlag.delete_all(["petition_id = ?", petition.id])
        Signature.delete_all(["petition_id = ?", petition.id])
        petition.delete
      end
      user.delete
    else
      puts "[WARNING] User #{email} for organisation #{organisation.host} doesn't exist"
    end
  end
end