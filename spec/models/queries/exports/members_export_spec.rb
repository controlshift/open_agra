require 'spec_helper'

describe Queries::Exports::MembersExport do
  before(:each) do
    @org1 = Factory(:organisation)
    @org2 = Factory(:organisation)
    @user_no_join = Factory(:user, organisation: @org1, email: "user_no_join@domain.com", join_organisation: false)
    @user_join = Factory(:user, organisation: @org1, email: "user_join@domain.com", join_organisation: true)
    @user2_join = Factory(:user, organisation: @org2, email: "user2_join@domain2.com", join_organisation: true)
    duplicated_email = "newguy1@email.com"
    petition = Factory(:petition, organisation: @org1)
    petition2 = Factory(:petition, organisation: @org1)
    @user_email1 = Factory(:user, organisation: @org1, first_name: "user_email1", email: duplicated_email, join_organisation: true)
    @sign_no_join = Factory(:signature, email: "sign_no_join@domain.com", join_organisation: false, petition: petition)
    @sign_join = Factory(:signature, email: "sign_join@domain.com", join_organisation: true, petition: petition)
    @sign_email1 = Factory(:signature, first_name: "sign_email1", email: duplicated_email, petition: petition, join_organisation: true)
    @sign_email2 = Factory(:signature, first_name: "sign_email2", email: duplicated_email, petition: petition2, join_organisation: true)
    @sign_pre_update = Factory(:signature, email: "updated@email.com", first_name: "pre-update", petition: petition, join_organisation: true)
    @sign_post_update = Factory(:signature, email: "updated@email.com", first_name: "post-update", petition: petition2, join_organisation: true)
  end

  def assert_contains(set, target)
    found = set.find {|person| person['email'] == target.email}
    found.should_not be_nil
  end

  def assert_not_contains(set, target)
    found = set.find {|person| person['email'] == target.email}
    found.should be_nil
  end

  def assert_unique(set, target)
    found = set.find_all {|person| person['email'] == target.email}
    found.count.should == 1
  end

  it "should only export people who have joined the organisation" do
    people = ActiveRecord::Base.connection.execute(Queries::Exports::MembersExport.new(organisation: @org1).sql_for_batch(1000, 0))
    assert_contains(people, @user_join)
    assert_contains(people, @user_email1)
    assert_contains(people, @sign_join)
    assert_contains(people, @sign_email1)
    assert_contains(people, @sign_post_update)
    assert_not_contains(people, @user_no_join)
    assert_not_contains(people, @sign_no_join)
  end
end

