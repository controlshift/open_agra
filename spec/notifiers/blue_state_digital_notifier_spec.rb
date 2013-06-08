require 'spec_helper'
require 'blue_state_digital/connection'
require 'blue_state_digital/constituent'

describe BlueStateDigitalNotifier do

  describe "#notify_category_update" do
    context "with a mock category" do
      before(:each) do
        @category = mock()
        @organisation = mock()
      end

      it "should not notify if api host is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new(nil, 'id', 'secret').notify_category_update(organisation: @organisation, category: @category).should be_false
      end

      it "should not notify if api id is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', nil, 'secret').notify_category_update(organisation: @organisation, category: @category).should be_false
      end

      it "should not notify if api secret is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', 'id', nil).notify_category_update(organisation: @organisation, category: @category).should be_false
      end
    end

    context "with a real category" do
      before(:each) do
        @organisation = Factory.build(:organisation)
        @category = Factory(:category, organisation: @organisation)
      end

      it "should rename the BSD Constituent Group" do
          attrs = { name: "Controlshift: #{@category.name}", slug: "controlshift-#{@category.name}", create_dt: @category.created_at.utc.to_i }
          cons_group = BlueStateDigital::ConstituentGroup.new(id: "1234")

          @category.stub!(:external_id).and_return('456')
          @category.stub!(:external_id=).with('1234')
          @category.should_receive(:save!)

          BlueStateDigital::Connection.should_receive(:new).with({host: 'host', api_id:'id', api_secret: 'secret'}).and_return( connection = mock() )
          connection.should_receive(:constituent_groups).and_return(constituent_groups = mock())
          constituent_groups.should_receive(:rename_group).with('456', attrs[:name]) { cons_group }

          notifier = BlueStateDigitalNotifier.new('host', 'id', 'secret')
          notifier.should_not_receive(:notify_category_creation)
          notifier.notify_category_update(organisation: @organisation, category: @category).should be_true
      end

      it "should create BSD Constituent Group if category does not already have one" do
        @category.external_id = nil
        params = {organisation: @organisation, category: @category}

        notifier = BlueStateDigitalNotifier.new('host', 'id', 'secret')
        notifier.should_receive(:notify_category_creation).with(params).and_return(true)
        notifier.notify_category_update(params).should be_true
      end
    end
  end
  
  describe "#notify_category_creation" do
    context "with a mock category" do
      before(:each) do
        @category = mock()
        @organisation = mock()
      end

      it "should not notify if api host is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new(nil, 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
      end

      it "should not notify if api id is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', nil, 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
      end

      it "should not notify if api secret is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', 'id', nil).notify_category_creation(organisation: @organisation, category: @category).should be_false
      end
    end

    context "with a real category" do
      before(:each) do
        @organisation = Factory.build(:organisation)
        @category = Factory(:category, organisation: @organisation)
      end

      it "should create BSD Constituent Group" do
        Timecop.freeze(Time.now) do
          attrs = { name: "Controlshift: #{@category.name}", slug: "controlshift-#{@category.name}", create_dt: Time.now.utc.to_i }
          cons_group = BlueStateDigital::ConstituentGroup.new(id: "1234")

          BlueStateDigital::Connection.should_receive(:new).with({host: 'host', api_id:'id', api_secret: 'secret'}).and_return( connection = mock() )
          connection.should_receive(:constituent_groups).and_return(constituent_groups = mock())
          constituent_groups.should_receive(:find_or_create).with(attrs) { cons_group }

          @category.should_receive(:external_id=).with('1234')
          @category.should_receive(:save!)

          BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_true
        end
      end

      it "should not create BSD Constituent Group is category already has one" do
        @category.external_id = '1234'

        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_category_creation(organisation: @organisation, category: @category).should be_false
      end
    end
  end
  
  describe "#notify_sign_up" do
    context "mocked petition and org" do
      before(:each) do
        @petition = mock()
        @organisation = mock()
        @user_details = mock()
      end

      it "should not notify if api host is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new(nil, 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details).should be_false
      end

      it "should not notify if api id is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', nil, 'secret').notify_sign_up(petition: @petition, user_details: @user_details).should be_false
      end

      it "should not notify if api secret is blank" do
        BlueStateDigital::Connection.should_not_receive(:new)
        BlueStateDigitalNotifier.new('host', 'id', nil).notify_sign_up(petition: @petition, user_details: @user_details).should be_false
      end

      it "should notify, fail and raise exception" do
        @organisation = Factory.build(:organisation)
        @petition = Factory.build(:petition, organisation: @organisation)
        @user_details = Factory.stub(:user)
        error = Exception.new
        BlueStateDigital::Connection.should_receive(:new).and_raise(error)
        -> { BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details, organisation: @organisation, role: 'signer') }.should raise_error
      end
    end

    describe "successful notification" do
      before(:each) do
        @organisation = Factory.build(:organisation)
        @petition = Factory.build(:petition, organisation: @organisation)
        @user_details = Factory.stub(:user)


        category = Factory.build(:category, organisation: @organisation, external_id: "1234")
        @petition.categories << category

        cons_data = mock
        cons_data.stub(:id) { "123" }
        cons_data.stub(:is_new?) { true }

        BlueStateDigital::Connection.stub(:new)
            .with({host: 'host', api_id:'id', api_secret: 'secret'})
            .and_return( @connection = mock() )

        input = %q{<?xml version="1.0" encoding="utf-8"?>}
        input << "<api>"
        input << "<cons>"
        input << "<firstname>#{@user_details.first_name}</firstname>"
        input << "<lastname>#{@user_details.last_name}</lastname>"
        input << "<create_dt>#{@user_details.created_at}</create_dt>"
        input << "<cons_email>"
        input << "<email>#{@user_details.email}</email>"
        input << "<is_subscribed>#{ @user_details.join_organisation? ? 1 : 0 }</is_subscribed>"
        input << "</cons_email>"

        input << '<cons_addr>'
        input << "<zip>#{@user_details.postcode}</zip>"
        input << '<is_primary>1</is_primary></cons_addr>'
        input << "<cons_phone><phone>#{@user_details.phone_number}</phone>"
        input << '<phone_type>unknown</phone_type></cons_phone>'
        input << "</cons>"
        input << "</api>"

        output = %q{<?xml version="1.0" encoding="utf-8"?>}
        output << "<api>"
        output << "<cons is_new='1' id='329'>"
        output << "</cons>"
        output << "</api>"

        @connection.stub(:constituent_groups).and_return(@constituent_groups = mock())

        cg = BlueStateDigital::ConstituentGroup.new()
        cg.id = '42'
        @constituent_groups.should_receive(:find_or_create).any_number_of_times.and_return(cg)

        @connection.should_receive(:perform_request).with('/cons/set_constituent_data', {}, "POST", input).and_return(output)
      end

      it "should set constituent data" do
        BlueStateDigitalConstituentWorker.should_receive(:perform_async).with('329', ['1234', '42', '42', '42'], {host: 'host', api_id: 'id', api_secret: 'secret'})
        BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details, organisation: @organisation, role: 'signer').should be_true
        @petition.bsd_constituent_group_id.should_not be_nil
        @user_details.external_constituent_id.should == "329"
      end

      it "should set data for the creator of the campaign" do
        BlueStateDigitalConstituentWorker.should_receive(:perform_async).with('329', ['1234', '42', '42', '42', '42'], {host: 'host', api_id: 'id', api_secret: 'secret'})

        BlueStateDigitalNotifier.new('host', 'id', 'secret').notify_sign_up(petition: @petition, user_details: @user_details, organisation: @organisation, role: 'creator').should be_true
        @petition.bsd_constituent_group_id.should_not be_nil
      end
    end
  end

  describe ".petition_signatures_cons_group_id" do
    before(:each) do
      @organisation = Factory.build(:organisation)
      @petition = Factory.build(:petition, organisation: @organisation)
    end

    it "should create a cons group for the petition" do
      Timecop.freeze(Time.now) do
        BlueStateDigital::Connection.stub(:new)
             .with({host: 'host', api_id:'id', api_secret: 'secret'})
             .and_return( connection = mock() )

        cg = BlueStateDigital::ConstituentGroup.new()
        cg.id = '42'
        attrs = { name: "Controlshift: #{@petition.title} Signatures (#{@petition.slug})", slug: "controlshift-#{@petition.id}-#{@petition.slug}-signatures", create_dt: Time.now.utc.to_i }

        connection.stub(:constituent_groups).and_return(constituent_groups = mock())
        constituent_groups.should_receive(:find_or_create).with(attrs).and_return(cg)

        notifier = BlueStateDigitalNotifier.new('host', 'id', 'secret')
        notifier.send(:petition_signatures_cons_group_id, @petition)
      end
    end
  end
end
