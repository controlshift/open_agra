class Org::OrganisationController < Org::OrgController
  def show
  end

  def settings
  end

  def update
    if current_organisation.update_attributes(params[:organisation])
      redirect_to settings_org_path, notice: t('controllers.organisation.success_update')
    else
      render action: 'settings'
    end
  end
end