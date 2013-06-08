class Org::Organisation::PlaceholderController < Org::OrgController
  def show
  end

  def update
    if current_organisation.update_attributes(params[:organisation])
      redirect_to settings_org_path, notice: t('controllers.organisation.success_update')
    else
      render action: 'show'
    end
  end
end