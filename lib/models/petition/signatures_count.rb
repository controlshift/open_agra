class Array
  # efficient way to get signatures count for a set of petitions
  def includes_signatures_count
    petition_ids = self.map(&:id)
    signatures_counts = Signature.select("petition_id, COUNT(*) AS signatures_count")
                                 .where(petition_id: petition_ids)
                                 .group("petition_id")
    signatures_counts_map = signatures_counts.inject({}) { |m, o| m[o[:petition_id]] = o[:signatures_count]; m }

    self.each do |petition|
      petition.send(:write_attribute, :signatures_count, signatures_counts_map[petition.id].to_i)
    end
    self
  end
end

module Petition::SignaturesCount
  # expensive way to get signatures count for a set of petitions, useful if sorting is required
  def join_and_includes_signatures_count
    select("petitions.*, COUNT(signatures.id) AS signatures_count")
    .joins("LEFT OUTER JOIN signatures ON signatures.petition_id = petitions.id")
    .group("petitions.id")
    .where("signatures.deleted_at IS NULL")
  end
end