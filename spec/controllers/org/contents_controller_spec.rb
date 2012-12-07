require 'spec_helper'

describe Org::ContentsController do
  include_context "setup_default_organisation"
  
  context "signed in as admin" do
    before(:each) do
      sign_in Factory(:org_admin, organisation: @organisation)
    end

    describe "#index" do
      before(:each) do 
        Content.should_not_receive(:where)
        get :index
      end

      it { should_not assign_to :contents }
      it { should render_template :index }
      it { should_not redirect_to '/' }
    end
    
    describe "#index with catgegory" do
      before(:each) do
        finder = mock()
        finder.should_receive(:where).with(:organisation_id => nil, :category => Content::CATEGORIES[0]).and_return(@contents = mock())
        Content.should_receive(:text).and_return(finder)

        get :index, :category => Content::CATEGORIES[0]
      end
      
      it { should assign_to :contents }
    end
  
    it "should redirect to contents page when unknown category requested" do
      get :index, :category => 'i-am-made-up'
      should redirect_to org_contents_path
      assigns[:content].should be_nil
    end

    describe "#new" do
      before(:each) do
        @content = Factory(:content, :organisation_id => nil)
        get :new, id: @content.slug
      end
    
      it "should move the variables across to the new content object from the template" do
        [:slug, :body, :filter].each do |field|
          assigns[:content].send(field).should == @content.send(field)
        end  
      end
    
      it "should assign the curent organisation" do
        assigns[:content].organisation.should == @organisation
      end
    
      it "should return a new object" do
        assigns[:content].new_record?.should == true
      end
    
      it { should render_template :new }
    end
    
    describe "#create" do
      before(:each) do
        post :create, :content => Factory.attributes_for(:content, :organisation_id => nil)
      end
      
      it "should create a content object" do
        assigns[:content].new_record?.should == false
        assigns[:content].organisation.should == @organisation
      end
      
      it { should redirect_to org_contents_path }
    end
    
    describe "#edit" do
      before(:each) do
        @content = Factory :content, organisation: nil, slug: 'foo'
      end
      
      context "an existing organisation content item" do
        before(:each) do
          @content = Factory :content, organisation: @organisation, slug: 'foo'
          get :edit, :id => 'foo'
        end
        it { should render_template :edit }

        it "should the existing item" do
          assigns[:content].should == @content
        end
      end
      
      context "no existing content" do
        before(:each) do
          get :edit, :id => 'foo'
        end
        
        it { should redirect_to new_org_content_path(:id => assigns[:content].slug)}
      end      
    end
    
    describe "#export" do
      before(:each) do
        @content = Factory(:content, organisation: @organisation, slug: 'foo')
      end
      
      it "should export all contents" do
        get :export
        response.headers["Content-Type"].should match 'application/json'
        response.body.should == [@content.to_hash].to_json
      end
      
      it "should export selected contents" do
        another_content = Factory(:content, organisation: @organisation, slug: 'boo')
        get :export, slug: ['boo']
        response.headers["Content-Type"].should match 'application/json'
        response.body.should == [another_content.to_hash].to_json
      end
      
      it "should alert user if no customised content to download" do
        get :export, slug: ['ha']
        response.should redirect_to migrate_org_contents_path
        flash[:alert].should match "No customised content to download."
      end
    end
    
    describe "#import" do
      before :each do
        filepath = Rails.root.join("spec/fixtures/sample_content.json")
        @content_params = JSON.parse(IO.read(filepath))
        @file = fixture_file_upload filepath, 'text/json'
      end
      
      it "should upload and import content" do
        Content.should_receive(:import).with(@organisation.id, @content_params)
        
        post :import, upload: @file
        response.should redirect_to migrate_org_contents_path
        flash[:notice].should match "successfully"
      end
      
      it "should show error message if failed to import" do
        Content.should_receive(:import).and_raise "Some error"
        
        post :import, upload: @file
        response.should redirect_to migrate_org_contents_path
        flash[:alert].should match "Some error"
      end
    end

    describe "#update" do
      before :each do
        @content = Factory(:content, category: 'Footer', organisation: @organisation)
        controller.stub(:current_organisation).and_return(@organisation)
      end

      it "should update attributes if valid" do
        @content.category.should == 'Footer'
        @content.category = 'Home'
        put :update, content: @content.attributes.symbolize_keys, id: @content
        Content.find(@content.id).category.should == 'Home'
        response.should redirect_to org_contents_path
      end

      it "should not update attributes if not valid" do
        @content.category.should == 'Footer'
        @content.category = ''
        put :update, content: @content.attributes.symbolize_keys, id: @content
        Content.find(@content.id).category.should == 'Footer'
        response.should render_template :edit
      end
    end
  end

  context "unauthorised access" do
    before(:each) do
      @unauthorised_org = Factory(:organisation)
      sign_in Factory(:org_admin, organisation: @unauthorised_org)
    end

    it "should deny unauthorised access to index, new" do
      [:index, :new].each do |action|
        get action
        should redirect_to '/'
      end
    end

    it "should deny unauthorised access to update, edit" do
      @content = Factory :content, organisation: @organisation, slug: 'foo'
      post :update, :id => @content.slug, :content => Factory.attributes_for(:content, :slug => @content.slug, :organisation_id => nil)
      should redirect_to '/'

      get :edit, :id => @content.slug
      should redirect_to '/'
    end

    it "should deny unauthorised access to create" do
      put :create, :content => Factory.attributes_for(:content, :organisation_id => nil)
      should redirect_to '/'
      put :create, :content => Factory.attributes_for(:content, :organisation_id => @organisation)
      should redirect_to '/'
      put :create, :content => Factory.attributes_for(:content, :organisation_id => @unauthorised_org)
      should redirect_to '/'
    end
  end
end
