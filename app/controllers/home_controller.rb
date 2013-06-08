class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, :all

  def index
    @featured_stories = Story.featured_stories(current_organisation)
    @featured_petitions = Petition.featured_homepage_petitions(current_organisation)
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
