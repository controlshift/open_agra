class Org::Efforts::LeadersController < Org::OrgController
  before_filter :load_and_authorize_effort

  def show
    @user = @petition.user
    @admins = @petition.admins.reject { |a| a == @user }
  end

  def destroy
    @petition.user = nil
    if @petition.save
      redirect_to org_effort_path(@effort)
    else
      render :show
    end
  end

  private

  def load_and_authorize_effort
    @effort = Effort.find_by_slug!(params[:effort_id])
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation
    authorize_or_redirect! :manage, @effort

    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
    raise ActiveRecord::RecordNotFound if @effort != @petition.effort
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end