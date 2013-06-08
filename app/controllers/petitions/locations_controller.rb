class Petitions::LocationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    render json: (Rails.cache.fetch ["locations_json", current_organisation, params[:category], params[:country]], expires_in: 15.minutes do
      query = Queries::ClusteredPetitionsQuery.new(organisation: current_organisation, category: Category.find_by_slug(params[:category]), country: params[:country])
      query.locations_as_json
    end)
  end

end