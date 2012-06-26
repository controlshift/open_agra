class EffortsController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    @effort = Effort.find_by_slug!(params[:id])

    if params[:location]
      latitude = params[:location][:latitude].to_f
      longitude = params[:location][:longitude].to_f
      
      query = Queries::Petitions::EffortLocationQuery.new(organisation: current_organisation,
                                                          latitude: latitude, longitude: longitude, effort: @effort)
      query.execute!
      @petitions = query.petitions
    else
      @petitions = @effort.petitions.appropriate
    end
  end
end