class Org::EmailWhiteListsController < Org::OrgController
  def new
    @whitelist = EmailWhiteList.new
  end

  def create
    @whitelist = EmailWhiteList.new params[:email_white_list]
    if @whitelist.save
      redirect_to new_org_email_white_list_path, :notice => t('controllers.org.email_white_list.success_create')
    else
      render :new
    end
  end
end
