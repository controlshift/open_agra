class Petitions::CategoriesController < ApplicationController
  include PetitionUpdateHelper

  before_filter :load_and_authorize_petition
  respond_to :json

  def show
    render json: @petition.categories.order('name').to_json(only: [:id, :name])
  end

  def update
    if update_petition(@petition, params[:petition])
      render json: @petition.categories(true).order('name').to_json(only: [:id, :name])
    else
      render json: @petition.errors
    end
  end

  private
  def load_and_authorize_petition
    @petition = Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end
end