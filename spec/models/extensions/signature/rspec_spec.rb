require 'spec_helper'

describe Extensions::Signature::Rspec do
  context "when loaded into a signature" do
    let(:signature){ Signature.new default_organisation_slug: 'rspec' }

    describe "default boolean field behaviors" do
      specify { signature.should respond_to(:magician)}
      specify { signature.should respond_to(:magician?)}
      specify { signature.magician.should be_nil}
      specify { signature.magician?.should be_false}
    end

    describe "when the person is a magician" do
      specify do
        signature.magician = true
        signature.magician?.should be_true
      end
    end

    describe "validation" do
      it "should validate presence of magician_kind" do
        signature.valid?
        signature.should have(0).error_on(:magician)
        signature.should have(1).error_on(:magician_kind)
        signature.magician_kind = 'Sorcerer'
        signature.valid?
        signature.should_not have(1).error_on(:magician_kind)
      end
    end

    describe "#assign_attributes" do
      it "should be accessible after assignments" do
        signature.assign_attributes(magician: true)
        signature.magician.should == true
      end
    end

    describe "cached_organisation_slug" do
      it "should, when saved, remember the organisation slug" do
        signature.assign_attributes(attributes_for(:signature).merge(magician: 'true', magician_kind: 'sorcerer'))
        signature.petition = Factory(:petition)
        signature.save!
        signature.reload
        signature.cached_organisation_slug == 'rspec'
      end
    end

    describe "additional field configs" do
      it "should contain a magician config" do
        signature.additional_field_configs[:magician].should_not be_nil
      end

      it "should not contain fields that do not exist" do
        signature.additional_field_configs[:witch].should be_nil
      end
    end

    describe "persistance" do
      it "should allow additional fields to be persisted" do
        signature.assign_attributes(attributes_for(:signature).merge(magician: 'true', magician_kind: 'sorcerer'))
        signature.petition = Factory(:petition)
        signature.save!
        signature.reload
        signature.magician?.should be_true
      end
    end

    describe "default_organisation_field" do
      specify{ signature.should respond_to(:default_organisation_slug) }
    end

    describe "accessible_attributes" do
      specify{ signature.accessible_attributes.keys.should include(:magician) }
    end

    describe "#accessible_attribute_names" do
      specify{ signature.accessible_attribute_names.should == %w(default_organisation_slug email postcode first_name last_name phone_number join_organisation join_group source akid magician magician_kind) }
    end
  end

  it "should not modify the behavior of other signatures" do
    #setup two signatures in organisations with different additional_field settings
    signature1 = Signature.new default_organisation_slug: 'rspec'
    signature2 = Signature.new

    # test that the behavior is transmitted into the intended organisation
    signature1.should respond_to(:magician)
    signature1.should respond_to(:magician?)
    signature1.additional_field_configs.should == {:magician => { as: :boolean, label: 'Are you a magician?' }, :magician_kind => {:as=>:string, :label=>"Kind of magician", :validation_options=>{:presence=>true}}}
    #signature1.should respond_to(:_additional_field_configs)


    # test for leakage into another organisation
    signature2.should_not respond_to(:magician)
    signature2.should_not respond_to(:magician?)
    signature2.additional_field_configs.should == {}
    signature2.should respond_to(:_additional_field_configs)

    # test for leakage into the parent class
    #Signature.should_not respond_to(:_additional_field_configs)
  end
end