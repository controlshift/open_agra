require "spec_helper"

describe "Liquid tags" do
  context "a petition object" do
    before(:each) do
      @organisation = mock('organisation')
      @organisation.stub!(:host).and_return('localhost')
      @organisation.stub!(:twitter_account_name).and_return('@twitter')

      @petition = mock('petition')
      @petition.stub!(:id).and_return(1)
      @petition.stub!(:organisation).and_return(@organisation)
      @petition.stub!(:updated_at).and_return(Time.now)
      @petition.stub!(:title).and_return('title')
      @petition.stub!(:why).and_return('why')


      @context = Liquid::Context.new({'petition' => @petition})
    end
    describe "facebook share" do
      subject { Liquid::FacebookShareUrl.new('share_url', {}, {})}

      it "should render the tag into an appropriate link" do
        subject.render(@context).should =~ /facebook.com/
      end
    end

    describe "Twitter share" do
      subject { Liquid::TwitterShareUrl.new('share_url', {}, {})}

      it "should render the tag into an appropriate link" do
        subject.render(@context).should =~ /twitter.com/
      end
    end
  end
end