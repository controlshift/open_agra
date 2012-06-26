class Efforts::NearController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :load_effort

  def new

  end

  def index
    latitude = params[:location][:latitude].to_f
    longitude = params[:location][:longitude].to_f

    query = Queries::Petitions::EffortLocationQuery.new(organisation: current_organisation,
                                                        latitude: latitude, longitude: longitude, effort: @effort)
    query.execute!
    @petitions = query.petitions

  end

  def load_effort
    @effort = Effort.find_by_slug!(params[:effort_id])
  end
end