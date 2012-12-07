class Groups::PetitionsController < ApplicationController
  layout 'sidebar', only: [:index, :hot]
  skip_before_filter :authenticate_user!, only: [:new]
  before_filter :load_and_authorize_group, only: [:index, :hot]

  def new
    @group = Group.find_by_slug!(params[:group_id])
    @petition = Petition.new
    @petition.group = @group
  end

  def index
    @list = Queries::Petitions::List.new( sort_direction: params[:direction],
                              sort_column:    params[:sort],
                              page:           params[:page],
                              conditions:     { organisation_id: current_organisation.id, group_id: @group.id })
  end

  def hot
    @petitions = Petition.hot([current_organisation], [@group])
  end

  private

  def load_and_authorize_group
    @group = Group.find_by_slug!(params[:group_id])
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation

    authorize! :manage, @group
  end

end