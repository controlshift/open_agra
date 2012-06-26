require 'blue_state_digital/connection'
require 'blue_state_digital/constituent_data'
require 'blue_state_digital/constituent_group'

class BlueStateDigitalNotifier
  CONS_GROUP_PREFIX =  'controlshift'

  def initialize(api_host, api_id, api_secret)
    @api_host = api_host
    @api_id = api_id
    @api_secret = api_secret
  end

  def notify_sign_up(params = {})
    if api_params_presents?
      petition        = params[:petition]
      user_details    = params[:user_details]
      cons_group_ids  = petition.categories.select {|c| c.external_id.present? }.map {|c| c.external_id }
      
      BlueStateDigital::Connection.establish(@api_host, @api_id, @api_secret)
      cons_data = BlueStateDigital::ConstituentData.set(format_data(user_details))

      unless cons_group_ids.nil?
        cons_group_ids.each do |group_id|
          BlueStateDigital::ConstituentGroup.add_cons_ids_to_group(group_id, cons_data.id)
        end
      end
      
      return true
    end
    false
  end
  
  def notify_category_creation(params = {})
    if api_params_presents?
      category = params[:category]
      return if category.external_id.present?
      
      BlueStateDigital::Connection.establish(@api_host, @api_id, @api_secret)
      attrs = { name: "#{CONS_GROUP_PREFIX.capitalize}: #{category.name}",
                slug: "#{CONS_GROUP_PREFIX}-#{category.slug}",
                create_dt: category.created_at.utc.to_i }
      cons_group = BlueStateDigital::ConstituentGroup.create(attrs)
      category.external_id = cons_group.id
      category.save!
      return true
    end
    false
  end

  private
  
  def api_params_presents?
    @api_host.present? && @api_id.present? && @api_secret.present?
  end

  def format_data(user_details)
    {
      firstname: user_details.first_name, 
      lastname: user_details.last_name,
      create_dt: user_details.created_at,
      emails: [{ email: user_details.email, is_subscribed: user_details.join_organisation? ? 1 : 0 }]
    }
  end
end
