require 'spec_helper'

describe HomeController do
  context "an organisation with rspec slug, that has an overridden template" do
    render_views(true)
    before(:each) do
      @current_org = Factory.build(:organisation, slug: 'rspec')
      Story.stub(:featured_stories).and_return([])
      Petition.stub(:featured_homepage_petitions).and_return([])
      Organisation.stub(:find_by_host).and_return(@current_org)
      controller.stub(:current_organisation).and_return(@current_org)
      get :index
    end

    it "should render the special overridden template" do
      response.body.should match(/rspec test homepage/)
    end
    
    it "should include a link to the right css" do
      response.body.should match(/organisations\/rspec\/application.css/)
    end

    it "should include the organisation title" do
      response.body.should match(/\<title\>\s*#{@current_org.name}/)
    end

  end

  describe "google analytics tracking" do
    context "an organisation with a tracking code" do
      render_views(true)
      before(:each) do
        @current_org = Factory.build(:organisation, google_analytics_tracking_id: 'foo')
        Organisation.stub(:find_by_host).and_return(@current_org)
        controller.stub(:current_organisation).and_return(@current_org)
        get :index
      end

      it "should render the code" do
        response.body.should match(/foo/)
      end

      it "should include the tracking js" do
        response.body.should match(/google-analytics/)
      end
    end

    context "an organisation without a tracking code" do
      render_views(true)
      before(:each) do
        @current_org = Factory.build(:organisation)

        Organisation.stub(:find_by_host).and_return(@current_org)
        controller.stub(:current_organisation).and_return(@current_org)

        get :index
      end

      it "should not render the code" do
        response.body.should match(/foo/)
      end

      it "should not include the tracking js" do
        response.body.should_not match(/google-analytics/)
      end

    end
  end

  context "stubbed current organisation" do
    include_context "setup_default_organisation"

    describe "#intro" do
      before(:each) do
        get :intro
      end
      it { response.should be_success }
      it { response.should render_template(:intro) }
    end

    describe "#index" do
      describe "basics" do
        before(:each){ get :index }
        it { response.should be_success }
        it { response.should render_template(:index) }
      end
    end
  end

  describe "#show_login_link" do
    it "should return true" do
      controller.send(:show_login_link).should be_true
    end
  end

  describe "set locale" do
    before(:each) do
      @current_org = Factory.build(:organisation)

      Organisation.stub(:find_by_host).and_return(@current_org)
      controller.stub(:current_organisation).and_return(@current_org)
    end

    it "should be able to change the default locale from the params passed" do
      I18n.locale.should == :en
      request.env["HTTP_ACCEPT_LANGUAGE"] = 'en-IN'
      get :index
      I18n.locale.should == 'en-IN'.to_sym
    end
  end
end
