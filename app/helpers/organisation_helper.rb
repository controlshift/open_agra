module OrganisationHelper

  def twitter_image_link
    link_to image_tag( 'footer-icon-twitter.png'), "http://www.twitter.com/#{current_organisation.twitter_account_name}", class: "follow twitter vmiddle" if current_organisation.twitter_account_name.present?
  end

  def facebook_image_link
    link_to image_tag( 'footer-icon-facebook.png'), current_organisation.facebook_url, class: "follow facebook vmiddle ml10" if current_organisation.facebook_url.present?
  end

end
