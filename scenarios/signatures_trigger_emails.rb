require File.dirname(__FILE__) + '/scenario_helper.rb'

describe Petitions::SignaturesController, :type => :controller do
  include Shoulda::Matchers::ActionMailer

  subject{Petitions::SignaturesController}

  describe '#create' do
    before :each do
      SeedFu.seed
    end
    
    it "should not send petition encouragement emails before signature targets" do
      @petition = Factory(:petition, organisation: @current_organisation)
      @petition.signatures.should be_empty
      (1..(SignaturesService::ENCOURAGEMENT_TARGET-1)).each do |i|
        post :create, {signature: Factory.attributes_for(:signature), petition_id: @petition}
      end
      should_not have_sent_email.with_subject(/Keep it up/noi)
      should_not have_sent_email.with_body(/needs another/i)
      should_not have_sent_email.to(@petition.email)
      (SignaturesService::ENCOURAGEMENT_TARGET..(SignaturesService::ACHIEVEMENT_TARGET - 1)).each do |i|
        post :create, {signature: Factory.attributes_for(:signature), petition_id: @petition}
      end
      should_not have_sent_email.with_subject(/well done/i)
      should_not have_sent_email.with_body(/just hit 100/i)
    end

    it "should send encouragement email" do
      @petition = Factory(:petition, organisation: @current_organisation)
      @petition.signatures.should be_empty
      (1..SignaturesService::ENCOURAGEMENT_TARGET).each do |i|
        post :create, {signature: Factory.attributes_for(:signature), petition_id: @petition}
      end
      should have_sent_email.with_subject(/Only 10 to go/i)
      should have_sent_email.from(@petition.organisation.contact_email)
      should have_sent_email.with_body(/needs another/i)
      should have_sent_email.to(@petition.email)
    end

    it "should send achieved goal email" do
      @petition = Factory(:petition, organisation: @current_organisation)
      @petition.signatures.should be_empty
      (1..SignaturesService::ACHIEVEMENT_TARGET).each do |i|
        post :create, {signature: Factory.attributes_for(:signature), petition_id: @petition}
      end
      should have_sent_email.with_subject(/You did it/i)
      should have_sent_email.from(@petition.organisation.contact_email)
      should have_sent_email.with_body(/achievement/i)
      should have_sent_email.to(@petition.email)
    end
  end

end