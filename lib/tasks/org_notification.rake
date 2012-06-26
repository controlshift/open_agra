namespace :org do
  namespace :notification do
    desc "import people through notification gateway"
    task import_people: :environment do
      slug = ENV['ORGANISATION']
      organisation = Organisation.find_by_slug(slug)
      raise 'Cannot find organisation' if organisation.nil?

      notify_url = ENV['URL']
      raise 'Requires notification URL' if notify_url.nil?
      organisation.notification_url = notify_url

      num_of_creators = 0
      num_of_signers = 0
      notifier = OrgNotifier.new

      organisation.petitions.not_orphan.each do |petition|
        if petition.user.join_organisation?
          notifier.notify_sign_up(organisation: organisation, petition: petition, user_details: petition.user, role: 'creator')
          num_of_creators += 1
        end
        
        petition.signatures.each do |signature|
          if signature.join_organisation?
            notifier.notify_sign_up(organisation: organisation, petition: petition, user_details: signature, role: 'signer')
            num_of_signers += 1
          end
        end
      end

      puts "Number of creators imported: #{num_of_creators}"
      puts "Number of signers imported: #{num_of_signers}"
    end

    desc "set organsation notification url"
    task set_url: :environment do
      slug = ENV['ORGANISATION']
      organisation = Organisation.find_by_slug(slug)
      raise 'Cannot find organisation' if organisation.nil?

      notify_url = ENV['URL']
      raise 'Requires notification URL' if notify_url.nil?

      organisation.update_attribute(:notification_url, notify_url)
      puts "Set organisation notification url to: #{notify_url}"
    end

    desc "import people and set notification url"
    task setup: [:import_people, :set_url]
  end
end