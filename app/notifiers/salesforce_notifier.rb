class SalesforceNotifier

  attr_accessor :organisation

  def notify_sign_up(params = {})
    begin
      petition        = params[:petition]
      user_details    = params[:user_details]
      self.organisation    = params[:organisation]

      Rails.logger.debug "notify new #{params[:role]}"

      client = organisation.salesforce_client

      if user_details.external_constituent_id.nil?


        salesforce_person = Salesforce::Contact.find_by_Email(user_details.email)
        if salesforce_person.present?
          salesforce_person.update_attributes(present_attributes(user_details))
        else
          salesforce_person = Salesforce::Contact.create(present_attributes(user_details))
        end
        user_details.external_constituent_id = salesforce_person.Id
        user_details.save

        Rails.logger.debug "Saved or updated constituent #{user_details.external_constituent_id}"
      else
        Rails.logger.debug "#{user_details.external_constituent_id} already exists, creating Campaign Memberships"
      end

      create_campaign_for_petition(petition) if petition.external_id.blank?
      begin
        Salesforce::CampaignMember.create('CampaignId' => petition.external_id, 'ContactId' => user_details.external_constituent_id)
      rescue Databasedotcom::SalesForceError => e
        ExceptionNotifier::Notifier.background_exception_notification(e)
      end
      if params[:role] == 'creator'
        create_campaign_for_petition_creators(organisation) if organisation.petition_creators_external_id.blank?
        begin
          Salesforce::CampaignMember.create('CampaignId' => organisation.petition_creators_external_id, 'ContactId' => user_details.external_constituent_id)
        rescue Databasedotcom::SalesForceError => e
          ExceptionNotifier::Notifier.background_exception_notification(e)
        end
      end

      return true
    rescue RestClient::Exception => e
      ExceptionNotifier::Notifier.background_exception_notification(e)
    end

    return false
  end

  private

  def create_campaign_for_petition(petition)
    Rails.logger.debug "Creating campaign for #{petition.slug}."
    name = "#{petition.slug} signers".slice(0..79)

    params = {
        'Type' => 'ControlShift',
        'Description' => "Signers of the campaign '#{petition.title}' on the ControlShift Toolset",
        'IsActive' => 'true'}

    params = params.merge('Primary_Lead__c' => petition.user.external_constituent_id) if petition.user

    result = Salesforce::Campaign.upsert('Name', name, params)
    if result.body.blank?
      petition.external_id = Salesforce::Campaign.find_by_Name(name).Id
    else
      petition.external_id = JSON.parse(result.body)["id"]
    end

    petition.save
  end

  def create_campaign_for_petition_creators(organisation)
    Rails.logger.debug "Creating CS petition creators group."
    result = Salesforce::Campaign.upsert('Name', "ControlShift petition creators", {
                                'Type' => 'ControlShift',
                                'Description' => "Members who have created a petition",
                                'IsActive' => 'true'}
                                )
    if result.body.blank?
      organisation.petition_creators_external_id = Salesforce::Campaign.find_by_Name("ControlShift petition creators").Id
    else
      organisation.petition_creators_external_id = JSON.parse(result.body)["id"]
    end
    organisation.save
  end

  def present_attributes(user_details)
   format_data(user_details).delete_if{|key, value| value.blank?}
  end

  def format_data(user_details)
    default_fields = {
      'FirstName' =>  user_details.first_name,
      'LastName' => user_details.last_name,
      'MailingPostalCode' => user_details.postcode,
      'Phone' => user_details.phone_number,
      'Email' => user_details.email,
    }

    begin
      extension_module = "Notifiers::Salesforce::#{organisation.slug.capitalize}".constantize
      custom_fields = extension_module.custom_fields(user_details)

      default_fields.merge!(custom_fields)
    rescue NameError
      # no-op
    ensure
      return default_fields
    end

  end
end
