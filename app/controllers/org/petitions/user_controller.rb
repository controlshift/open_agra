class Org::Petitions::UserController < Org::OrgController
  before_filter :load_and_authorize_petition

  def edit
  end

  def update
    user = current_organisation.users.where(email: params[:user][:email]).first
    if user
      @petition.user = user
      @petition.save
      redirect_to org_petition_path(@petition)
    else
      flash[:notice] = t('controllers.org.petitions.user.does_not_exist', user_email: params[:user][:email])
      render 'edit'
    end
  end

  private

  def load_and_authorize_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end
