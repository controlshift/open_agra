require "spec_helper"

describe ErrorsController do
  before(:each) do
    controller.stub(:current_organisation).and_return(Factory.build(:organisation))
  end

  specify { get 'not_found';  response.should render_template :not_found}
  specify { get 'internal_server_error';  response.should render_template :internal_server_error}

  describe "pingdom" do
    render_views(true)
    it "returns the proper string" do
      get :pingdom
body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<pingdom_http_custom_check>
  <status>OK</status>
  <response_time>1</response_time>
</pingdom_http_custom_check>"

      response.body.should == body
    end
  end

end
