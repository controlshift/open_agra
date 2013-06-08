class Efforts::NearController < ApplicationController
  layout 'application_sidebar'
  skip_before_filter :authenticate_user!
  before_filter :load_effort

  def new
  end

  def index
    @petitions =  @effort.order_petitions_by_location(params[:location])
    @closest_petition = @petitions.first
    @other_petitions_nearby = @petitions.slice(1..@petitions.length)

    if @closest_petition.present? && @closest_petition.user.present?
      redirect_to petition_path(@closest_petition)
    end
  end

  private

  def load_effort
    @effort = Effort.find_by_slug!(params[:effort_id])
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation
  end
end