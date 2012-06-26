require 'spec_helper'

class DummyClass
  def initialize(petition)
    @petition = petition
  end
  include PetitionFilters
end

describe PetitionFilters do
  before(:each) do
    @petition = Petition.new
    @petition.admin_status = :inappropriate
    @subject = DummyClass.new(@petition)
  end

  it "it should redirect an inappropriate petition" do
    @subject.should_receive(:redirect_to)
    @subject.should_receive(:petition_manage_path).with(@petition)

    @subject.send(:verify_petition_can_be_managed)
  end
end