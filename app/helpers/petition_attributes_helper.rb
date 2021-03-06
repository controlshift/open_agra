module PetitionAttributesHelper
  def attributes_for_petition(hash)
    hash.symbolize_keys.slice(:image, :title, :who, :what, :why, :delivery_details,
                              :campaigner_contactable, :effort_id, :group_id, :source, :categorized_petitions_attributes,
                              :share_on_facebook, :share_with_friends_on_facebook, :share_on_twitter, :share_via_email, :external_site, :external_facebook_page)
  end

  def attributes_for_categorized_petitions(petition, category_ids)
    attributes = []
    unless category_ids.nil?
      new_category_ids = case category_ids
      # handle single select id
      when String then [category_ids.to_i]
      # convert the category_ids to an array of integer and exclude 0 from it
      when Array then category_ids.map {|cid| cid.to_i }.reject {|cid| cid == 0 }
      end

      # remove deselected
      if petition
        petition.categorized_petitions.each do |categorized_petition|
          unless new_category_ids.include?(categorized_petition.category_id)
            attributes << { id: categorized_petition.id, _destroy: '1' }
          end
          new_category_ids.delete(categorized_petition.category_id)
        end
      end

      # petition id or nil
      petition_id = petition ? petition.id : nil

      # add newly selected
      new_category_ids.each do |category_id|
        attributes << { category_id: category_id, petition_id: petition_id }
      end
    end
    attributes
  end
end
