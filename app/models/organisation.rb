# == Schema Information
#
# Table name: organisations
#
#  id                           :integer         not null, primary key
#  name                         :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  slug                         :string(255)
#  host                         :string(255)
#  contact_email                :string(255)
#  parent_name                  :string(255)
#  admin_email                  :string(255)
#  google_analytics_tracking_id :string(255)
#  blog_link                    :string(255)
#  notification_url             :string(255)
#  sendgrid_username            :string(255)
#  sendgrid_password            :string(255)
#  campaigner_feedback_link     :string(255)
#  user_feedback_link           :string(255)
#  use_white_list               :boolean         default(FALSE)
#  parent_url                   :string(255)
#  facebook_url                 :string(255)
#  twitter_account_name         :string(255)
#  settings                     :text
#  uservoice_widget_link        :string(255)
#

class Organisation < ActiveRecord::Base
  include BooleanFields
  store :settings, accessors: [:notifiers, :requires_user_confirmation_on_sign_up,
                               :fb_app_id, :fb_app_secret, :enable_facebook_login,
                               :salesforce_host, :salesforce_consumer_key, :salesforce_consumer_secret,
                               :salesforce_username, :salesforce_security_token,
                               :bsd_host, :bsd_api_id, :bsd_api_secret,
                               :bsd_new_members_cons_group_id, :bsd_all_signatures_cons_group_id,
                               :bsd_campaign_creator_cons_group_id, :google_maps_key, :country,
                               :show_share_buttons_on_petition_page, :show_petition_category_on_creation,
                               :action_kit_host, :action_kit_username, :action_kit_password, 
                               :action_kit_country, :action_kit_signature_page, :action_kit_petition_page,
                               :requires_location_for_campaign, :always_join_parent_org_when_sign_up, :join_label,
                               :hide_signatures_csv_download_link, :signature_disclaimer]
  
  validates :name, :slug, :host, presence: true, uniqueness: true
  validates :host, format: {with: /^(?!http:\/\/).+/, message: 'only include the hostname, not the protocol'}
  validates :contact_email, :admin_email, presence: true, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  has_many :petitions
  has_many :stories
  has_many :categories
  has_many :signatures, through: :petitions
  has_many :blast_emails
  has_many :users
  has_many :members
  has_many :targets

  liquid_methods :name, :host, :campaigner_feedback_link, :has_campaigner_feedback_link?

  boolean_fields :enable_facebook_login, :show_share_buttons_on_petition_page, :requires_user_confirmation_on_sign_up,
                 :requires_location_for_campaign, :always_join_parent_org_when_sign_up,
                 :show_petition_category_on_creation, :hide_signatures_csv_download_link

  def self.find_by_host(host)
    where('lower(host) = ?', host.downcase).first
  end

  def contact_email_with_name
    "\"#{name}\" <#{contact_email}>"
  end
  
  def sendgrid_username
    read_attribute(:sendgrid_username).presence || ENV['SENDGRID_USERNAME']
  end
  
  def sendgrid_password
    read_attribute(:sendgrid_password).presence || ENV['SENDGRID_PASSWORD']
  end
  
  def has_campaigner_feedback_link?
    self.campaigner_feedback_link.present?
  end

  def skip_white_list_check?
    !use_white_list?
  end

  def combined_name
    n = name
    n += " and #{parent_name}" if parent_name.present?
    n
  end

  def signatures_count_key
    "#{id}_organisation_signatures_count"
  end

  def cached_signatures_size
    return @cached_signatures_size if defined?(@cached_signatures_size) # return immediately if we have already calculated this

    @cached_signatures_size = Rails.cache.fetch(signatures_count_key, raw: true) do
      signatures.size
    end
    @cached_signatures_size  = @cached_signatures_size.to_i # we need to do this, because we store as raw in memcached.
  end

  def salesforce_client
    @salesforce_client ||= Salesforce.initialize_client({host: salesforce_host, client_id: salesforce_consumer_key, client_secret: salesforce_consumer_secret,
                                  username: salesforce_username, password: salesforce_security_token})
  end


end
