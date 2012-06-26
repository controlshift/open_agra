require "uri"
require "net/http"

class TijuanaNotifier

  def notify_sign_up(params = {})
    petition      = params[:petition]
    user_details  = params[:user_details]
    organisation  = petition.organisation
    role          = params[:role]
    
    if organisation.notification_url.present? && user_details.join_organisation?
      json = params_json(petition.slug, user_details, role)
      response = Net::HTTP.post_form(URI.parse(organisation.notification_url), data: json)
      response.value # this raises an exception if the value is not 2XX. cf. http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTPResponse.html#method-i-value
      return true
    end
    false
  end

  private

  def params_json(petition_slug, user_details, role) 
    { slug: petition_slug, first_name: user_details.first_name, last_name: user_details.last_name,
      email: user_details.email, postcode: user_details.postcode, phone_number: user_details.phone_number, role: role}.to_json
  end
end
