# == Schema Information
#
# Table name: comments
#
#  id            :integer         not null, primary key
#  text          :text
#  up_count      :integer         default(0)
#  approved      :boolean
#  flagged_at    :datetime
#  flagged_by_id :integer
#  signature_id  :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  featured      :boolean         default(FALSE)
#

require 'spec_helper'

describe Comment do

  context "with a comment" do
    before(:each) do
      @comment = Factory(:comment)
    end

    it { should validate_uniqueness_of(:signature_id)}
  end
  it { should ensure_length_of(:text).is_at_least(10).
              is_at_most(500)}

  it "should be able to create a comment for a signature" do
    comment = Factory(:comment)
    comment.signature = Factory :signature, :petition => Factory(:petition)
    comment.flagged_by = Factory :user
    comment.save!
    comment.signature.should_not be_nil
    comment.flagged_by.should_not be_nil
    comment.created_at.should_not be_nil
  end

  describe "#flagged?" do
    subject { Comment.new }

    it "should be true if flagged_at" do
      subject.flagged_at = Time.now
      subject.flagged?.should be_true
    end

    it "should be false if nil" do
      subject.flagged?.should be_false
    end
  end

  describe "#hidden?" do
    it "should be false by default" do
      subject.hidden?.should be_false
    end
  end

  describe "#visible?" do
    subject { Comment.new }

    it "should be true by default" do
      subject.visible?.should be_true
    end

    context "flagged" do
      before(:each) { subject.flagged_at = Time.now }
      specify { subject.visible?.should be_false }

      context "and approved" do
        before(:each) { subject.approved = true }
        specify { subject.visible?.should be_true }
      end
    end
  end
end
