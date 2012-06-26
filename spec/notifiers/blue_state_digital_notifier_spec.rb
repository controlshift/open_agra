require 'spec_helper'
require 'blue_state_digital/connection'
require 'blue_state_digital/constituent_data'

describe BlueStateDigitalNotifier do
  before(:each) do
    @organisation = Factory.build(:organisation)
  end
  
  describe "#notify_category_creation" do
    before(:each) do
      @category = Factory(:category, organisation: @organisation)
    end
    
    it "should not notify if api host is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new(nil, 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
    end
    
    it "should not notify if api id is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new('host', nil, 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
    end
    
    it "should not notify if api secret is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new('host', 'id', nil).notify_category_creation(organisation: @organisation, category: @category).should be_false
    end
    
    it "should create BSD Constituent Group" do
      Timecop.freeze(Time.now) do
        attrs = { name: "Controlshift: #{@category.name}", slug: "controlshift-#{@category.name}", create_dt: Time.now.utc.to_i }
        cons_group = BlueStateDigital::ConstituentGroup.new(id: "1234")

        BlueStateDigital::Connection.should_receive(:establish).with('host', 'id', 'secret')
        BlueStateDigital::ConstituentGroup.should_receive(:create).with(attrs) { cons_group }

        @category.should_receive(:external_id=).with('1234')
        @category.should_receive(:save!)

        BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_true
      end
    end
    
    it "should not create BSD Constituent Group is category already has one" do
      @category.external_id = '1234'
      
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
    end
  end
  
  describe "#notify_sign_up" do
    before(:each) do
      @petition = Factory.build(:petition, organisation: @organisation)
      @user_details = Factory.stub(:user)
    end
    
    it "should not notify if api host is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new(nil, 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details).should be_false
    end
    
    it "should not notify if api id is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new('host', nil, 'secret').notify_sign_up(petition: @petition, user_details: @user_details).should be_false
    end
    
    it "should not notify if api secret is blank" do
      BlueStateDigital::Connection.should_not_receive(:establish)
      BlueStateDigitalNotifier.new('host', 'id', nil).notify_sign_up(petition: @petition, user_details: @user_details).should be_false
    end
    
    it "should notify, fail and raise exception" do
      BlueStateDigital::Connection.should_receive(:establish).with('host', 'id', 'secret')
      error = Exception.new
      BlueStateDigital::ConstituentData.should_receive(:set).and_raise(error)
      
      -> { BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details) }.should raise_error
    end
    
    it "should set constituent data" do
      category = Factory.build(:category, organisation: @organisation, external_id: "1234")
      @petition.categories << category
      
      data = {
        firstname: @user_details.first_name,
        lastname: @user_details.last_name,
        create_dt: @user_details.created_at,
        emails: [{ email: @user_details.email, is_subscribed: @user_details.join_organisation? ? 1 : 0 }],
      }
      cons_data = mock
      cons_data.stub(:id) { "123" }
      
      BlueStateDigital::Connection.should_receive(:establish).with('host', 'id', 'secret')
      BlueStateDigital::ConstituentData.should_receive(:set).with(data) { cons_data }
      BlueStateDigital::ConstituentGroup.should_receive(:add_cons_ids_to_group).with("1234", "123")

      BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details).should be_true
    end
  end
end
