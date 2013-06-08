class ActionKitNotifier < Notifier::Base
  attr_accessor :ak

  def initialize(host, username, password)
    @ak = ActionKitRest.new(host: host, username: username, password: password)
  end

  def process_sign_up
    begin
      # initial sign up
      action = Adapters::ActionKit::Action.new(params)
      hsh = action.to_hash
      Rails.logger.debug("Publishing #{hsh.inspect} to AK")
      sign = ak.action.create(hsh)

      user_id = user_id_from_uri(sign.user)
      user_details.external_constituent_id = user_id
      user_details.member.external_id = user_id
      if user_details.is_a?(Signature)
        user_details.external_id = sign.id
        user_details.new_member  = sign.created_user
      end

      user_details.member.save!
      user_details.save!

      if user_details.is_a?(User)
        ak.action.create(action.to_hash(organisation.petition_creators_external_id))
      end

    rescue Exception => e
      RestExceptionMailer.exception_email(e, params).deliver
      raise e
    end

    return true
  end

  private

  def ensure_external_petition_present
    if petition.external_id.blank?
      page = Adapters::ActionKit::Page.new(params)
      page = ak.import_page.find_or_create(page.to_hash)
      petition.external_id = page.name
      petition.save!
    end

    return true
  end

  def ensure_creators_page_present
    if organisation.petition_creators_external_id.blank?
      page = ak.import_page.find_or_create(title: 'ControlShift Petition Creators', name: 'controlshift_petition_creators')
      organisation.petition_creators_external_id = page.name
      organisation.save!
    end

    return true
  end

  def ensure_category_pages_present
    petition.categories.each do |category|
      if category.external_id.blank?
        name = "ControlShift Category: #{category.name}"
        tag = ak.tag.find_or_create(name)
        category.external_id = tag_id_from_resource_uri(tag.resource_uri)
        category.save!
      end
    end

    if organisation.action_kit_tag_id.blank?
      tag = ak.tag.find_or_create('ControlShift')
      organisation.action_kit_tag_id = tag_id_from_resource_uri(tag.resource_uri)
      organisation.save!
    end

    return true
  end

  def tag_id_from_resource_uri(resource_uri)
    resource_uri.match(/\/rest\/v1\/tag\/(\d*)\//)[1]
  end

  def user_id_from_uri(uri)
    uri.match(/\/rest\/v1\/user\/(\d*)\//)[1]
  end
end
