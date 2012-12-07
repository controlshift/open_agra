class EffortsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :load_effort

  def show
    @petitions = @effort.order_petitions_by_location(params[:location])
    if @effort.specific_targets?
      render 'show_specific_targets_effort'
    else
      render 'show'
    end
  end

  def locations
    @locations = @effort.petition_locations
    render json: @locations
  end

  private

  def load_effort
    @effort = Effort.find_by_slug!(params[:id])
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation
  end
end