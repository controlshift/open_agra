require 'spec_helper'

describe UnsubscribeHelper do
  context "petition email" do
    let(:email)do
      m = mock_model(PetitionBlastEmail)
      petition = mock_model(Petition)
      petition.stub(:id).and_return(1001)
      m.stub(:petition).and_return(petition)
      m
    end
    it "should return a petition unsub link" do
      url = helper.blast_email_unsubscribe_url(email)
      url.should == "http://test.host/petitions/1001/signatures/___token___/unsubscribing"
    end
  end

  context "group email" do
    let(:email) do
      group = mock_model(Group)
      group.stub(:id).and_return(1001)
      m = mock_model(GroupBlastEmail)
      m.stub(:group).and_return(group)
      m
    end
    it "should return a group unsub link" do
      url = helper.blast_email_unsubscribe_url(email)
      url.should == "http://test.host/groups/1001/unsubscribes/___token___"
    end
  end
end