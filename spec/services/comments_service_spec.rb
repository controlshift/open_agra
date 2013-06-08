require 'spec_helper'

describe CommentsService do
  subject{CommentsService.new}

  it "should respond to save" do
    subject.should respond_to(:save)
  end

  context "service callbacks on comment save" do
    before(:each) do
      @organisation = Factory(:organisation, notification_url: 'foo')
      @petition = Factory(:petition, organisation: @organisation)
      @signature = Factory(:signature, petition: @petition)
    end

    after :each do
      Rails.cache.clear
    end

    it "should trigger service callbacks after create" do
      comment = mock()
      comment.stub(:new_record?).and_return(true)
      comment.stub(:signature).and_return(@signature)
      comment.stub(:save).and_return(true)

      subject.should_receive(:increment_count_if_not_profane)
      subject.save(comment)
    end

    describe "with a comment" do
      let(:comment) do
        comment = Comment.new(text: "test text for comment")
        comment.signature = @signature
        comment
      end

      it "should trigger service callbacks after create but not increment if comment is profane" do
        comment.approved = false

        Rails.cache.read(@petition.comments_count_key).should == nil
        subject.save(comment)
        Rails.cache.read(@petition.comments_count_key).should == 0
      end

      it "should increment the cache if comment was saved" do
        Rails.cache.read(@petition.comments_count_key).should == nil
        subject.save(comment)
        Rails.cache.read(@petition.comments_count_key).should == 1
      end
    end

    it "should update the petition comments_updated_at" do
      comment = Factory(:comment, signature: @signature, flagged_at: nil)
      @signature.stub(:petition).and_return(petition = mock())
      petition.stub(:comments_count_key).and_return("key")
      petition.stub(:comments_size).and_return(5)
      Petition.should_receive(:update_all)
      subject.stub(:current_object).and_return(comment)
      subject.save(comment)
    end
  end
end