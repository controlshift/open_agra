class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, :all

  #has_mobile_fu
  #has_no_mobile_fu_for [:index]
  #

  def index
    @featured_stories = Story.featured
                             .where(:organisation_id => current_organisation.id)
                             .order("updated_at DESC")
                             .all.rotate(-1)
    @featured_petitions = Petition.awesome.limit(3).where(:organisation_id => current_organisation.id)
  end

  def intro
  end

  def about_us
  end

  def tos
  end

  def privacy_policy
  end
end
