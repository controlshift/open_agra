require 'spec_helper'

describe SignatureMailer do

  describe "Sending thank you email to signer" do
    before :each do
      @organisation = Factory.create(:organisation)
      @petition = Factory.create(:petition, user: Factory(:user), organisation: @organisation)
      @signature = Factory.create(:signature, petition: @petition)
      @email = SignatureMailer.thank_signer(@signature).deliver
    end

    subject { @email }

    specify { ActionMailer::Base.deliveries.should_not be_empty }
    specify { subject.to.should == [@signature.email] }
    specify { subject.from.should == [@signature.petition.organisation.contact_email] }
    specify { subject.body.should match confirm_destroy_petition_signature_url(@petition, @signature, host: @organisation.host) }
    specify { subject.body.should match petition_url(@petition, host: @organisation.host) }
    specify { subject.header['From'].to_s.should include @petition.organisation.name }
  end
  
  describe "Sanitize email content" do
    before :each do
      @petition = Factory(:petition, 
                          user: Factory(:user), 
                          title: "<b>Bold Title</b>",
                          why: "<i>Why</i> with <script> alert('why') </script> tag.")
      @signature = Factory.create(:signature, :petition => @petition)
      @email = SignatureMailer.thank_signer(@signature).deliver
    end

    subject { @email }
    
    specify { subject.body.should include "&lt;b&gt;Bold Title&lt;/b&gt;" }
    specify { subject.body.should_not include "<b>Bold Title</b>" }
  end
end
