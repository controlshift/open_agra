class Admin::OrganisationsController < Admin::AdminController
  def index
    @organisations = Organisation.paginate page: params[:page], order: 'created_at DESC'
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path, notice: t('controllers.organisation.success_create')
    else
      render action: 'new'
    end
  end

  def edit
    @organisation = Organisation.find params[:id]
  end

  def update
    @organisation = Organisation.find params[:id]
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisations_path, notice: t('controllers.organisation.success_update')
    else
      render action: 'edit'
    end
  end
end