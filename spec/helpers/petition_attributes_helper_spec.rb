require 'spec_helper'

describe PetitionAttributesHelper do

  describe "#attributes_for_petition" do
    it "should extract only accessible attributes" do
      petition_attributes = Factory.attributes_for(:petition, user: nil, organisation: nil, image: nil)
      petition_attributes.keys.should include :title
      petition_attributes.keys.should include :who
      petition_attributes.keys.should include :what
      petition_attributes.keys.should include :delivery_details
      petition_attributes.keys.should include :campaigner_contactable
      petition_attributes.keys.should include :image
      petition_attributes.keys.should include :admin_status
      petition_attributes.keys.should include :admin_notes
      petition_attributes.keys.should include :cancelled
      petition_attributes.keys.should include :launched
      petition_attributes.keys.should include :user
      petition_attributes.keys.should include :organisation

      petition_accessible_attributes = helper.attributes_for_petition(petition_attributes)
      petition_accessible_attributes.keys.should include :title
      petition_accessible_attributes.keys.should include :who
      petition_accessible_attributes.keys.should include :what
      petition_accessible_attributes.keys.should include :delivery_details
      petition_accessible_attributes.keys.should include :campaigner_contactable
      petition_accessible_attributes.keys.should include :image
      petition_accessible_attributes.keys.should_not include :admin_status
      petition_accessible_attributes.keys.should_not include :admin_notes
      petition_accessible_attributes.keys.should_not include :cancelled
      petition_accessible_attributes.keys.should_not include :launched
      petition_accessible_attributes.keys.should_not include :user
      petition_accessible_attributes.keys.should_not include :organisation
    end

    it "should handle string keys" do
      petition_attributes = Factory.attributes_for(:petition, user: nil, organisation: nil)

      petition_attributes.keys.should include :delivery_details
      petition_attributes.keys.should include :admin_status

      petition_attributes.stringify_keys!

      petition_accessible_attributes = helper.attributes_for_petition(petition_attributes)

      petition_accessible_attributes.keys.should include :delivery_details
      petition_accessible_attributes.keys.should_not include :admin_status
    end
  end
  
  describe "#attributes_for_categorized_petitions" do
    let(:category) { Factory(:category) }
    let(:petition) { Factory(:petition) }
    
    it "should return attributes for new categorized petition" do
      attributes = helper.attributes_for_categorized_petitions(petition, [category.id])
      attributes.first[:petition_id].should == petition.id
      attributes.first[:category_id].should == category.id
      attributes.first.keys.should_not include :id
      attributes.first.keys.should_not include :_destroy
    end
    
    it "should return attributes for deleted categorized petition" do
      petition.categories << category
      categorized_petition_id = petition.categorized_petitions.first.id
      attributes = helper.attributes_for_categorized_petitions(petition, [])
      attributes.first[:id].should == categorized_petition_id
      attributes.first[:_destroy].should == "1"
      attributes.first.keys.should_not include :petition_id
      attributes.first.keys.should_not include :category_id
    end
    
    it "should return empty attributes existing categorized petition" do
      petition.categories << category
      categorized_petition_id = petition.categorized_petitions.first.id
      attributes = helper.attributes_for_categorized_petitions(petition, [category.id])
      attributes.length.should == 0
    end

    it "should handle the situation when category_ids and petitions are empty" do
      attributes = helper.attributes_for_categorized_petitions(nil, nil)
      attributes.length.should == 0
    end

    it "should handle the case when there is a new petition, and we are selecting categories" do
      attributes = helper.attributes_for_categorized_petitions(nil, [category.id])

      attributes.first[:petition_id].should == nil
      attributes.first[:category_id].should == category.id
      attributes.first.keys.should_not include :id
      attributes.first.keys.should_not include :_destroy
    end
  end
end