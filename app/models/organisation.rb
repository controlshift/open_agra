# == Schema Information
#
# Table name: organisations
#
#  id                           :integer         not null, primary key
#  name                         :string(255)
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
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
  store :settings, accessors: [:notifiers, :requires_user_confirmation_on_sign_up,
                               :fb_app_id, :fb_app_secret, :enable_facebook_login, 
                               :bsd_host, :bsd_api_id, :bsd_api_secret,
                               :google_maps_key,
                               :show_share_buttons_on_petition_page, :show_petition_category_on_creation,
                               :action_kit_host, :action_kit_username, :action_kit_password, 
                               :action_kit_country, :action_kit_signature_page, :action_kit_petition_page,
                               :requires_location_for_campaign, :always_join_parent_org_when_sign_up, :join_label]
  
  validates :name, :slug, :host, presence: true, uniqueness: true
  validates :host, format: {with: /^(?!http:\/\/).+/, message: 'only include the hostname, not the protocol'}
  validates :contact_email, :admin_email, presence: true, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  has_many :petitions
  has_many :stories
  has_many :categories
  has_many :signatures, :through => :petitions
  has_many :blast_emails, :through => :petitions
  has_many :users

  liquid_methods :name, :host, :campaigner_feedback_link, :has_campaigner_feedback_link?

  def self.find_by_host(host)
    where("lower(host) = ?", host.downcase).first
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
  
  def enable_facebook_login?
    self.enable_facebook_login == '1'
  end
  
  def show_share_buttons_on_petition_page?
    self.show_share_buttons_on_petition_page == '1'
  end
  
  def requires_user_confirmation_on_sign_up?
    self.requires_user_confirmation_on_sign_up == '1'
  end

  def requires_location_for_campaign?
    self.requires_location_for_campaign == '1'
  end

  def always_join_parent_org_when_sign_up?
    self.always_join_parent_org_when_sign_up == '1'
  end

  def show_petition_category_on_creation?
    self.show_petition_category_on_creation == '1'
  end

  def skip_white_list_check?
    !use_white_list?
  end

  def combined_name
    n = name
    n += " and #{parent_name}" if parent_name.present?
    n
  end
end
