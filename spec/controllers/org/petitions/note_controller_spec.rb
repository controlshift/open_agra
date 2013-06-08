require 'spec_helper'

describe Org::Petitions::NoteController do
  describe "#notes" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation)
      sign_in user
    end

    it "should save and update notes" do
      note = 'this is a new note'
      put :update, petition_id: @petition, petition: {admin_notes: note}, format: :js
      response.should be_success
      assigns(:petition).admin_notes.should == note

      new_note = 'an even newer note'
      put :update, petition_id: @petition, petition: {admin_notes: new_note}, format: :js
      response.should be_success
      assigns(:petition).admin_notes.should == new_note
    end
  end
end
