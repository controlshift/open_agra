require 'spec_helper'

describe HasSlug do
  context "an object with a slug" do
    before(:each) do
      @effort = Factory.build(:effort)
    end

    describe "create_slug" do
      before(:each) do
        @effort.title = "title param"
      end

      it "takes the title by default" do
        @effort.send(:create_slug!).should == 'title-param'
      end


      describe "if the default already exists" do
        before(:each) do
          Effort.should_receive(:find_by_slug).with('title-param').and_return(Effort.new)
        end

        it "should add 1" do
          Effort.should_receive(:find_by_slug).with('title-param-1').and_return nil
          @effort.send(:create_slug!).should == 'title-param-1'
        end

      end
    end

    it "should create slug for a new effort" do
      @effort.title = "This is a test"
      @effort.save!
      @effort.slug.should == "this-is-a-test"
    end

    it "should create an unique slug for a effort with a title that already exists" do
      existing_title = @effort.title
      existing_slug = @effort.slug
      new_effort = Factory.build(:effort)
      new_effort.title = existing_title
      new_effort.save!
      new_effort.slug.should_not == existing_slug
    end
  end
end