class Admin::VanityController < ApplicationController
  before_filter { authorize_or_redirect! :manage, :all }
  include Vanity::Rails::Dashboard
end