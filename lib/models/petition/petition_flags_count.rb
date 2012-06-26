class Array
  # efficient way to get petition flags count for a set of petitions
  def includes_petition_flags_count
    petition_ids = self.map(&:id)
    petition_flags_counts = PetitionFlag.select("petition_id, COUNT(*) AS petition_flags_count")
                                        .where(petition_id: petition_ids)
                                        .group("petition_id")
    petition_flags_counts_map = petition_flags_counts.inject({}) { |m, o| m[o[:petition_id]] = o[:petition_flags_count]; m }

    self.each do |petition|
      petition.send(:write_attribute, :petition_flags_count, petition_flags_counts_map[petition.id].to_i)
    end
    self
  end
end

module Petition::PetitionFlagsCount
  # expensive way to get petition flags count for a set of petitions, useful if sorting is required
  def join_and_includes_petition_flags_count
    select("petitions.*, COUNT(petition_flags.id) AS petition_flags_count")
    .joins("LEFT OUTER JOIN petition_flags ON petition_flags.petition_id = petitions.id")
    .group("petitions.id")
  end
end