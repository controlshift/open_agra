class Groups::UnsubscribesController < ApplicationController
  before_filter :load_subscription
  before_filter :load_group
  skip_before_filter :authenticate_user!

  def show
    @unsubscribe = GroupUnsubscribe.new(:subscription => @subscription)
  end

  def update
    @unsubscribe = GroupUnsubscribe.new(:subscription => @subscription, :email => params[:group_unsubscribe][:email].strip)

    if @unsubscribe.unsubscribe
      flash[:notice] = t('controllers.groups.unsubscribe.success',:group_title => @group.title)
      redirect_to group_path(@group)
    else
      render :show
    end

  end

  def load_subscription
    @subscription = GroupSubscription.find_by_token! params[:id]
  end

  def load_group
    @group = Group.find_by_slug!(params[:group_id])
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation
    raise ActiveRecord::RecordNotFound if @subscription.group != @group
  end

end
