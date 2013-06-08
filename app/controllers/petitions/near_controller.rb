class Petitions::NearController < ApplicationController
  layout 'application_sidebar'
  skip_before_filter :authenticate_user!
  before_filter :assign_countries

  def new
    @categories = if params[:category].present?
      [current_organisation.categories.find_by_slug(params[:category])]
    else
      current_organisation.categories
    end

    if params[:embed]
      render "iframe", :layout => 'iframe'
    else
      render "new"
    end
  end

  def index
    @petitions = current_organisation.order_petitions_by_location(params[:location], :category => current_organisation.categories.find_by_slug(params[:category]))

    if params[:redirect]
      redirect_to petition_path(@petitions.first)
    else
      @locations = @petitions.map { |petition| petition.location }
      render "new"
    end
  end

  private
  def assign_countries
    @countries = current_organisation.petitions.appropriate.joins(:location).select('petitions.updated_at as updated_at, locations.country as location_country').order('location_country ASC').uniq.map(&:location_country).compact.uniq
  end
end