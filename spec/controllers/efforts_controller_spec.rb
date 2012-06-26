require 'spec_helper'

describe EffortsController do
  include_context 'setup_default_organisation'

  before(:each) do
    @user = Factory(:user, organisation: @organisation)
    @effort = Factory(:effort, organisation: @organisation)
  end

  describe '#show' do

    it 'should render template show' do
      get :show, id: @effort
      assigns(:effort).should_not be_nil
      assigns(:petitions).should_not be_nil
      response.should render_template :show
    end

    context 'user specifies location' do
      it 'should return petitions order by nearest' do
        query = mock()
        petitions = mock()
        input_latitude = 2
        input_longitude = 2

        Queries::Petitions::EffortLocationQuery.stub(:new).with(organisation: @organisation,
                                                                latitude: input_latitude, longitude: input_longitude,
                                                                effort: @effort).and_return query
        query.should_receive(:execute!)
        query.stub(:petitions) { petitions }

        get :show, id: @effort, location: {latitude: input_latitude, longitude: input_longitude}

        assigns(:petitions).should == petitions
      end
    end

    context 'user does not specify location' do
      it 'should return all appropriate petition ' do
        effort = mock()
        petitions = mock()
        appropriate_petitions = mock()

        request.stub(:location) { OpenStruct.new(latitude: 1, longitude: 1) }
        Effort.stub(:find_by_slug!).with('1').and_return effort
        effort.stub(:petitions).and_return petitions
        petitions.stub(:appropriate).and_return appropriate_petitions

        get :show, id: '1'

        assigns(:petitions).should == appropriate_petitions
      end
    end

  end
end