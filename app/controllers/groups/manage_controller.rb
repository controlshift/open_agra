class Groups::ManageController < ApplicationController
  layout 'sidebar', except: [:index]
  before_filter :load_and_authorize_group

  def show
  end

  def export
    csv_string = Queries::PeopleForGroup.new.people_as_csv(@group.id)
    filename = "people-#{Time.now.strftime("%Y%m%d")}.csv"
    send_data(csv_string, type: 'text/csv; charset=utf-8; header=present', filename: filename)
  end

  private

  def load_and_authorize_group
    @group = Group.find_by_slug!(params[:group_id])
    authorize! :manage, @group
  end
end