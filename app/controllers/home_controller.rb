class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, :all

  #has_mobile_fu
  #has_no_mobile_fu_for [:index]
  #

  PETITION_COUNT_WITH_FEATURED_EFFORT = 2
  PETITION_COUNT_WITHOUT_FEATURED_EFFORT = 3

  def index
    @featured_stories = Story.featured
                             .where(:organisation_id => current_organisation.id)
                             .order("updated_at DESC")
                             .all.rotate(-1)
    @featured_effort = Effort.most_recently_featured(current_organisation).first

    petition_count =  @featured_effort.present? ? PETITION_COUNT_WITH_FEATURED_EFFORT : PETITION_COUNT_WITHOUT_FEATURED_EFFORT
    @featured_petitions = Petition.awesome.limit(petition_count).where(:organisation_id => current_organisation.id)
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
