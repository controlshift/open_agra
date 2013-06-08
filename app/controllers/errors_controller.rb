class ErrorsController < ApplicationController
  before_filter :authenticate_user!, except: [:not_found,:internal_server_error, :pingdom, :streaming]
  skip_before_filter :prepend_organisation_view_path, only: [:streaming]

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

  def streaming
    self.response.headers['Last-Modified'] = Time.now.httpdate

    count = 0
    self.response_body = Enumerator.new do |response|
      20.times do
        count = count +1
        response << "Hi #{count}"
        sleep(1)
      end
    end
  end
end
