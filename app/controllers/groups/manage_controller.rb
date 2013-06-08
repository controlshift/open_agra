class Groups::ManageController < ApplicationController
  layout 'sidebar', except: [:index]
  before_filter :load_and_authorize_group

  def show
  end

  def export
    streaming_csv(Queries::Exports::MembersForGroupExport.new(group_id: @group.id, organisation: current_organisation))
  end

  private

  def load_and_authorize_group
    @group = Group.find_by_slug!(params[:group_id])
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation
    authorize! :manage, @group
  end
end