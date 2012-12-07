class Array
  # efficient way to get petition flags or signatures count for a small set of petitions
  [:signatures, :petition_flags].each do |kind|
    define_method "includes_#{kind}_count".intern do
      kind_count_sym = "#{kind}_count".intern
      # either Signature or PetitionFlag
      klass = kind.to_s.classify.constantize

      petition_ids = self.map(&:id)
      counts = klass.select("petition_id, COUNT(*) AS #{kind}_count")
                                          .where(petition_id: petition_ids)
                                          .group("petition_id")
      counts_map = counts.inject({}) { |m, o| m[o[:petition_id]] = o[kind_count_sym]; m }

      self.each do |petition|
        petition.send(:write_attribute, kind_count_sym, counts_map[petition.id].to_i)
      end
      self
    end
  end
end

module EfficientCounts
  # expensive way to get petition flags count for a set of petitions, useful if sorting is required
  def join_and_includes_petition_flags_count
    select("petitions.*, COUNT(petition_flags.id) AS petition_flags_count")
    .joins("LEFT OUTER JOIN petition_flags ON petition_flags.petition_id = petitions.id")
    .group("petitions.id")
  end

  # expensive way to get signatures count for a set of petitions, useful if sorting is required
  def join_and_includes_signatures_count
    select("petitions.*, COUNT(signatures.id) AS signatures_count")
    .joins("LEFT OUTER JOIN signatures ON signatures.petition_id = petitions.id")
    .group("petitions.id")
    .where("signatures.deleted_at IS NULL")
  end
end
