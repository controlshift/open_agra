module Documents
  class MultiPetitionLetter < PetitionLetter

    attr_accessor :batch

    def table_data
      data = []
      data << ["Name", "Postcode"] + additional_field_keys.map(&:humanize)
      batch.each do |sign|
        data << [sign.full_name, sign.postcode] + additional_field_columns(sign)
      end
      data
    end
  end
end