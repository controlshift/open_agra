require 'spec_helper'

describe EffortsController do
  include_context 'setup_default_organisation'

  before(:each) do
    @user = Factory(:user, organisation: @organisation)
    @effort = Factory(:effort, organisation: @organisation)
  end

  describe '#show' do
    before(:each) do
      get :show, id: @effort
    end

    context 'should render template show' do
      it { should assign_to :effort }
      it { should assign_to :petitions }
      it { should render_template :show }
    end
  end
end