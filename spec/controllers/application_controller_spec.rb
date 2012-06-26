require 'spec_helper'

describe ApplicationController do
  # cancan exceptions are spec'd in admin/petitions_controller_spec
  
  describe "#current_organisation" do
    it "should find current organisation by host" do
      organisation = Factory(:organisation)
      @request.host = organisation.host
      controller.current_organisation.should == organisation
    end
    
    it "should raise exception if host does not match any organisation" do
      -> { controller.current_organisation }.should raise_error
    end
  end

  describe "#show_login_link" do
    it "should return true by default" do
      controller.send(:show_login_link).should be_true
    end
  end

  describe "#prepend view paths" do
    it 'should prepend with the private organisation folder' do
      private_path = mock
      controller.stub(:private_organisations_view_path).and_return(private_path)
      controller.should_receive(:private_organisations_view_path)
      controller.should_receive(:prepend_view_path).with(private_path)
      
      controller.send(:prepend_organisation_view_path)
    end

    describe '#private_organisations_view_path' do
      it 'should return the private view path of the current organisation' do
        organisation = mock('organisation')
        organisation.stub(:slug).and_return('rspec')
        controller.stub(:current_organisation).and_return(organisation)
        
        controller.send(:private_organisations_view_path).should include 'app/views/organisations/rspec'
      end
    end
  end
end
