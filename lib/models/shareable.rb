module Shareable
  def share_variant_ids
    facebook_share_variants.map(&:id).map(&:to_s)
  end

  def facebook_share
    @facebook_share ||= FacebookShare.new(petition: self)
  end
end