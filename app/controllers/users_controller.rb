class UsersController < ApplicationController
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if UsersService.new.update_attributes(@user, params[:user])
      if params[:user][:image].blank?
        redirect_to account_path, notice: t('controllers.user.success_update')
      else
        render :crop
      end    
    else
      render :edit
    end
  end
  
  def update_password
    @user = current_user
    if @user.update_with_password(params[:user_password])
      sign_in(@user, bypass: true)
      redirect_to account_path, notice: t('controllers.user.success_update_password')
    else
      render :edit
    end
  end
end