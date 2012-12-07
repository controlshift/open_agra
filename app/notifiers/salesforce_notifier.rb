class SalesforceNotifier

  def notify_sign_up(params = {})
    begin
      beginning_time = Time.now

      petition        = params[:petition]
      user_details    = params[:user_details]
      organisation    = params[:organisation]
      campaign_ids  = []
      campaign_ids  << petition.categories.select {|c| c.external_id.present? }.map {|c| c.external_id }

      if user_details.external_constituent_id.nil?

        client = organisation.salesforce_client

        salesforce_person = Salesforce::Contact.find_by_Email(user_details.email)
        if salesforce_person.present?
          salesforce_person.update_attributes(present_attributes(user_details))
        else
          salesforce_person = Salesforce::Contact.create(format_data(user_details))
        end
        user_details.external_constituent_id = salesforce_person.Id
        user_details.save

        Rails.logger.debug "Salesforce notify_sign_up for #{organisation.host} took #{(Time.now - beginning_time)} seconds."
      end

      return true
    rescue RestClient::Exception => e
      RestExceptionMailer.exception_email(e, params).deliver
      raise e
    end

    return false
  end


  private

  def present_attributes(user_details)
   format_data(user_details)
  end

  def format_data(user_details)
    {
      'FirstName' =>  user_details.first_name,
      'LastName' => user_details.last_name,
      'MailingPostalCode' => user_details.postcode,
      'Phone' => user_details.phone_number,
      'Email' => user_details.email
    }
  end
end
