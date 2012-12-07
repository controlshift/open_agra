require 'rest_client'

class ActionKitNotifier
  def initialize(host, username, password)
    @host = host
    @username = username
    @password = password
  end
  
  def notify_sign_up(params = {})    
    if api_params_presents?
      params[:category_slugs]  = params[:petition].categories.map {|c| c.slug }
      
      resource_uri  = "https://#{@username}:#{@password}@#{@host}/rest/v1/action/"
      data          = format_data(params)

      begin
        response = RestClient.post(resource_uri, data.to_json, content_type: :json, accept: :json)
        Rails.logger.debug "ActionKit response: #{response.inspect}"
      rescue RestClient::Exception => e
        RestExceptionMailer.exception_email(e, params).deliver
        raise e
      end
      return true
    else
      Rails.logger.error "ActionKit API parameters are not present."
      return false
    end
  end
  
  private
  
  def api_params_presents?
    @host.present? && @username.present? && @password.present?
  end
  
  def format_data(params)
    data = {
      page: page_for(params[:role], params[:organisation]),
      first_name: params[:user_details].first_name,
      last_name: params[:user_details].last_name,
      email: params[:user_details].email,
      zip: params[:user_details].postcode,
      created_at: params[:user_details].created_at
    }
    data[:country] = params[:organisation].action_kit_country if params[:organisation].action_kit_country.present?
    data[:action_categories] = params[:category_slugs] unless params[:category_slugs].empty?
    data
  end

  def page_for(role, organisation)
    case role
      when 'signer'
        organisation.action_kit_signature_page
      when 'creator'
        organisation.action_kit_petition_page
      else
        raise "Role #{role} has not been handled yet."
    end
  end
end
