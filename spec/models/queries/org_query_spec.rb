require 'spec_helper'

describe Queries::OrgQuery do

  it { should validate_presence_of(:query) }

  describe '#white_list_table_names' do
    let(:organisation) { Organisation.new(slug: 'getup') }
    it 'should add the suffix' do
      query = Queries::OrgQuery.new(organisation: organisation)
      query.white_list_table_names.should =~ %w(users_getup signatures_getup petitions_getup)
    end
  end

  describe "initialization" do
    it "should set the organisation and query" do
      q = Queries::OrgQuery.new organisation: 'foo', query: 'bar'
      q.organisation.should == 'foo'
      q.query.should == 'bar'
    end
  end

  describe "#query_fragments" do
    let(:organisation) { Organisation.new(slug: 'getup') }

    it "should split up queries into chunks" do
      q = Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users as u, petitions_getup as p where (SELECT * FROM users_getup) where (SELECT * FROM users_getup)', organisation: organisation)
      q.send(:query_fragments).should == ["SELECT users.id, user.last_name, petitions.title FROM users as u, petitions_getup as p where (SELECT * FROM users_getup) where (SELECT * FROM users_getup)", " users_getup) where (SELECT * FROM users_getup)"]
    end
  end

  describe '#execute' do
    before :each do
      @organisation = Factory(:organisation)
      5.times { |i| Factory(:user, organisation: @organisation) }
      @org_query = Queries::OrgQuery.new(query: 'select * from users', organisation: @organisation)
    end

    it 'should execute the query and store the result with a limit' do
      Queries::OrgQuery.stub(:limit_size).and_return(3)
      @org_query.should_receive(:valid?).and_return(true)

      @org_query.execute
      @org_query.result.should_not be_nil
      @org_query.result.count.should == 3
    end

    it 'should not execute if the query is not valid' do
      @org_query.should_receive(:valid?).and_return(false)

      @org_query.execute
      @org_query.result.should be_nil
    end

    it { Queries::OrgQuery::CONNECTION_TIMEOUT.should == 10000 }

    it 'executes within a transaction and rollback' do
      @org_query.should_receive(:valid?).and_return(true)

      old_slug = @organisation.slug
      sql = "update organisations set slug='anewslug' where id=#{@organisation.id}"
      @org_query.stub(:limit_query).and_return(sql)

      @org_query.execute
      Organisation.find_by_id(@organisation.id).slug.should == old_slug
    end
  end

  describe '#query_format' do
    let(:organisation) { Organisation.new(slug: 'getup') }

    it 'should include only select keyword' do
      Queries::OrgQuery.new(query: 'Update table', organisation: organisation).valid?.should be_false
      Queries::OrgQuery.new(query: 'delete * from', organisation: organisation).valid?.should be_false
      Queries::OrgQuery.new(query: 'acommand select *', organisation: organisation).valid?.should be_false

      Queries::OrgQuery.new(query: 'SElect *', organisation: organisation).valid?.should be_true
      Queries::OrgQuery.new(query: 'select *', organisation: organisation).valid?.should be_true
    end

    it 'should not allow semi-colon' do
      Queries::OrgQuery.new(query: 'SELECT * FROM users_getup JOIN signatures_getup;', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT * FROM users_getup JOIN signatures_getup; SELECT * FROM petitions_getup', organisation: organisation).should_not be_valid

      Queries::OrgQuery.new(query: 'SELECT * FROM users_getup JOIN signatures_getup', organisation: organisation).should be_valid
    end

    it 'should include only include table in the whitelist for FROM statement' do
      Queries::OrgQuery.new(query: 'SELECT * FROM users', organisation: organisation).valid?.should be_false
      Queries::OrgQuery.new(query: 'SElect * FROM signatures_another', organisation: organisation).valid?.should be_false

      Queries::OrgQuery.new(query: 'select * from users_getup', organisation: organisation).valid?.should be_true
      Queries::OrgQuery.new(query: 'select * FROM signatures_getup', organisation: organisation).valid?.should be_true
    end

    it 'should include only include table in the whitelist for JOIN statement' do
      Queries::OrgQuery.new(query: 'SELECT * FROM users', organisation: organisation).valid?.should be_false
      Queries::OrgQuery.new(query: 'SElect * FROM signatures_another', organisation: organisation).valid?.should be_false
      Queries::OrgQuery.new(query: 'select * from users_getup WHERE (SELECT * FROM users_getup JOIN signatures JOIN petitions_getup)', organisation: organisation).valid?.should be_false
      #
      Queries::OrgQuery.new(query: 'select * JOin users_getup', organisation: organisation).valid?.should be_true
      Queries::OrgQuery.new(query: 'select * JOIN signatures_getup', organisation: organisation).valid?.should be_true
      Queries::OrgQuery.new(query: 'select * JOIN users_getup WHERE (SELECT * FROM users_getup JOIN petitions_getup)', organisation: organisation).valid?.should be_true
    end

    it 'should allow user to select columns from different views' do
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users, petitions', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users_getup, petitions_getup', organisation: organisation).should be_valid
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users_getup, petitions', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users_getup as u, petitions_getup as p', organisation: organisation).should be_valid
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users as u, petitions_getup as p where (SELECT * FROM users_getup) where (SELECT * FROM users_getup)', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users_getup as u, petitions_getup as p where (SELECT * FROM users_getup) where (SELECT * FROM users)', organisation: organisation).should_not be_valid
    end

    it 'should allow user to select columns with join tables' do
      Queries::OrgQuery.new(query: 'SELECT users.id, user.last_name, petitions.title FROM users_getup JOIN petitions_getup ON something', organisation: organisation).should be_valid
    end

    it 'should not allow the keyword LIMIT' do
      Queries::OrgQuery.new(query: 'SELECT * FROM signatures_getup LIMIT 10', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT * FROM signatures_getup limit 10', organisation: organisation).should_not be_valid
      Queries::OrgQuery.new(query: 'SELECT * FROM signatures_getup', organisation: organisation).should be_valid
    end

  end

  describe '#limit_query' do
    it 'limits the query' do
      Queries::OrgQuery.limit_size.should == 50
      Queries::OrgQuery.new(query: 'select * from users').send(:limit_query).should == "select * from users LIMIT #{Queries::OrgQuery.limit_size}"
    end
  end
end