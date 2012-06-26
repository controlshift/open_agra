class Efforts::PetitionsController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
    @effort = Effort.find_by_slug!(params[:effort_id])
    @petition = Petition.new
    @petition.effort = @effort

    if @effort.ask_for_location?
      @petition.location = Location.new
    end
  end
end