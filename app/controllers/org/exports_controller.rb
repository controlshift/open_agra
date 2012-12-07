class Org::ExportsController < Org::OrgController
  def index
  end

  def signatures
    streaming_csv(Queries::Exports::SignaturesExport.new(organisation: current_organisation))
  end

  def petitions
    streaming_csv(Queries::Exports::PetitionsExport.new(organisation: current_organisation))
  end

  def members
    streaming_csv(Queries::Exports::MembersExport.new(organisation: current_organisation))
  end

end