require 'spec_helper'

describe Jobs::UpdateConstituentJob do
  before(:each) do
    @signature = Factory(:signature, external_constituent_id: '123', petition: Factory(:petition))
  end

  subject { Jobs::UpdateConstituentJob.new  }

  describe "#perform" do
    it "should perform without exception" do
      api_params = {host: 'host', api_id: 'api_id', api_secret: 'api_secret'}
      BlueStateDigital::Connection.should_receive(:new).with(api_params)
      BlueStateDigital::Constituent.should_receive(:new).and_return(cons = mock('cons'))
      cons.should_receive(:save)
      cons.stub(:id).and_return('123')
      cons.stub(:is_new?).and_return(false)

      subject.perform @signature.id, 'Signature', api_params
    end
  end
end
