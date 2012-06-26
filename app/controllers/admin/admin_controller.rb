class Admin::AdminController < ApplicationController
  before_filter { authorize_or_redirect! :manage, :all }

  def index
    render "admin/index"
  end

end
