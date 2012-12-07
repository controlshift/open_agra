require 'spec_helper'

describe BlueStateDigitalConstituentWorker do
  before(:each) do
    BlueStateDigital::Connection.stub(:new)
                .with({host: 'host', api_id:'id', api_secret: 'secret'})
                .and_return( @connection = mock() )

    @connection.stub(:constituent_groups).and_return(@constituent_groups = mock())
    @constituent_groups.should_receive(:add_cons_ids_to_group).with("1234", "329", wait_for_result: false)
  end

  it "should perform the necessary work" do
    BlueStateDigitalConstituentWorker.new.perform("329", ["1234"], {host: 'host', api_id:'id', api_secret: 'secret'})
  end

end