require 'blue_state_digital/connection'
require 'blue_state_digital/constituent'
require 'blue_state_digital/constituent_group'

class BlueStateDigitalNotifier
  CONS_GROUP_PREFIX =  'controlshift'

  def initialize(api_host, api_id, api_secret)
    @api_host = api_host
    @api_id = api_id
    @api_secret = api_secret
  end

  def notify_sign_up(params = {})
    begin
      if api_params_presents?
        api_parameters = {host: @api_host, api_id: @api_id, api_secret: @api_secret}

        petition        = params[:petition]
        user_details    = params[:user_details]
        organisation    = params[:organisation]
        cons_group_ids  = []
        cons_group_ids  << petition.categories.select {|c| c.external_id.present? }.map {|c| c.external_id }

        connection = BlueStateDigital::Connection.new(api_parameters)
        cons = BlueStateDigital::Constituent.new(format_data(user_details).merge({connection: connection}))
        cons.save
        user_details.external_constituent_id = cons.id
        user_details.save!

        cons_group_ids  << campaign_creator_cons_group_id(organisation) if params[:role] == 'creator'
        cons_group_ids  << all_signatures_cons_group_id(organisation)
        cons_group_ids  << new_members_cons_group_id(organisation) if cons.is_new?
        cons_group_ids  << petition_signatures_cons_group_id(petition)
        cons_group_ids.flatten!

        BlueStateDigitalConstituentWorker.perform_async(cons.id, cons_group_ids, api_parameters)

        return true
      end
    rescue RestClient::Exception => e
      RestExceptionMailer.exception_email(e, params).deliver
      raise e
    end

    return false
  end
  
  def notify_category_creation(params = {})
    if api_params_presents?
      category = params[:category]
      return if category.external_id.present?
      
      connection = BlueStateDigital::Connection.new({host: @api_host, api_id: @api_id, api_secret: @api_secret})

      attrs = cons_group_attrs(category.name, category.created_at.utc.to_i)
      cons_group = connection.constituent_groups.find_or_create(attrs)
      category.external_id = cons_group.id
      category.save!
      return true
    end
    false
  end

  def notify_category_update(params = {})
    if api_params_presents?
      category = params[:category]
      if category.external_id.present?
        connection = BlueStateDigital::Connection.new({host: @api_host, api_id: @api_id, api_secret: @api_secret})


        attrs = cons_group_attrs(category.name, category.created_at.utc.to_i)
        cons_group = connection.constituent_groups.replace_constituent_group!(category.external_id, attrs)

        category.external_id = cons_group.id
        category.save!
        return true
      else
        return notify_category_creation(params)
      end
    end
    false
  end

  private

  def petition_signatures_cons_group_id(petition)
    attributes = {
      name: "#{CONS_GROUP_PREFIX.capitalize}: #{petition.title} Signatures (#{petition.slug})",
      slug: "#{CONS_GROUP_PREFIX}-#{petition.id}-#{petition.slug}-signatures",
      create_dt: Time.now.utc.to_i
    }
    get_or_create_constituent_group_id(petition, :bsd_constituent_group_id, attributes)
  end

  def all_signatures_cons_group_id(organisation)
    name = :bsd_all_signatures_cons_group_id
    get_or_create_constituent_group_id(organisation, name, cons_group_attrs(name))
  end

  def new_members_cons_group_id(organisation)
    name =  :bsd_new_members_cons_group_id
    get_or_create_constituent_group_id(organisation, name, cons_group_attrs(name))
  end

  def campaign_creator_cons_group_id(organisation)
    name = :bsd_campaign_creator_cons_group_id
    get_or_create_constituent_group_id(organisation, name, cons_group_attrs(name))
  end

  def cons_group_attrs(name, created_at = Time.now.utc.to_i )
    { name: "#{CONS_GROUP_PREFIX.capitalize}: #{name}",
      slug: "#{CONS_GROUP_PREFIX}-#{name}",
      create_dt: created_at}
  end


  def get_or_create_constituent_group_id(obj, field_name, attributes)
    # obj is either a petition or an organisation
    if obj.send(field_name).present?
      return obj.send(field_name)
    else
      connection = BlueStateDigital::Connection.new({host: @api_host, api_id: @api_id, api_secret: @api_secret})

      cons_group = connection.constituent_groups.find_or_create(attributes)
      obj.send("#{field_name}=".intern, cons_group.id)
      obj.save!
      return obj.send(field_name)
    end
  end

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
