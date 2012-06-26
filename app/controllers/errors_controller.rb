class ErrorsController < ApplicationController
  before_filter :authenticate_user!, except: [:not_found,:internal_server_error, :pingdom]

  def not_found
    render :not_found, status: :not_found
  end

  def internal_server_error
    render :internal_server_error, status: :internal_server_error
  end
  
  # convenient way to test if exception notification is working.
  def exception
    raise "EXCEPTION NOTIFICATION TEST"
  end

  def pingdom
    render 'pingdom', layout: false
  end
end
