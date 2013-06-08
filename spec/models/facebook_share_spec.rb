require 'spec_helper'

describe FacebookShare do

  describe "initialization" do
    it "should setup the session from a variant" do
      variant = FactoryGirl.build_stubbed(:facebook_share_variant, petition: FactoryGirl.build_stubbed(:petition))
      fbshare = FacebookShare.new(variant: variant)
      fbshare.petition.should == variant.petition
    end
  end

  describe "choose" do
    it "should return the variant id" do
      petition = FactoryGirl.create(:petition, slug: 'slug')
      share_variant = FactoryGirl.create(:facebook_share_variant, petition: petition)
      petition.stub(:facebook_share_variants).and_return([share_variant])
      share = FacebookShare.new(petition: petition)
      share.choose
      share.variant_id.should == share_variant.id
    end
  end

  context "a petition with a variant" do
    let(:petition) { FactoryGirl.create(:petition) }
    let(:variant)  { FactoryGirl.create(:facebook_share_variant, petition: petition)}

    before(:each) do
      petition.facebook_share_variants << variant
      petition.save
    end

    describe "experiment" do
      it "should have an experiment" do
        fbshare = FacebookShare.new(petition: petition)
        fbshare.experiment.should_not be_nil
      end

      it "the experiment should have the alternatives from the petition variants" do
        petition.facebook_share_variants.should == [variant]
        fbshare = FacebookShare.new(petition: petition)
        fbshare.experiment.alternatives.should_not be_empty
        fbshare.experiment.alternatives.collect{|a| a.name}.should == ["#{variant.id}"]
      end
    end

    describe "integration" do
      it "should choose and then allow a record!, followed by a complete!" do
        petition.facebook_share.choose
        petition.facebook_share.variant.should_not be_nil
        petition.facebook_share.variant_id.should_not be_nil

        petition.facebook_share.record!
        petition.facebook_share.complete!
      end
    end
  end

  describe "randomisation and selection" do
    let(:petition) { FactoryGirl.create(:petition) }
    before(:each) do
      @variant1 = FactoryGirl.create(:facebook_share_variant, title: "share message 1", petition: petition)
      @variant2 = FactoryGirl.create(:facebook_share_variant, title: "share message 2", petition: petition)
    end

    it "should select one of the choices" do
      petition.facebook_share.choose
      [@variant1.id, @variant2.id].should include(petition.facebook_share.variant_id)
    end

    it "should preference the choice with more completions" do
      # this spec sets up 100 previous preference recordings in an attempt
      # to bias the results of the experiment strongly towards variant1.

      @variant2.split_alternative.increment_participation
      @variant2.split_alternative.increment_completion


      500.times do
        @variant2.split_alternative.increment_participation

        @variant1.split_alternative.increment_participation
        @variant1.split_alternative.increment_completion
      end

      # we then run 100 dice rolls in order to demonstrate that the result that should
      # receive preferential choice actually does.

      answers = []
      100.times do
        petition.facebook_share.choose
        answers << petition.facebook_share.variant.title
      end

      counts = Hash.new(0)
      answers.each { |name| counts[name] += 1 }

      # Across 100 trials, the multi armed bandit algorithm should choose share message 1
      # more times than share message 2, since previous users have expressed a preference
      # for share message 1.

      counts["share message 1"].should > counts["share message 2"]
    end
  end
end
