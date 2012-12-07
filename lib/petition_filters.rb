module PetitionFilters
  private

  def verify_petition_can_be_managed
    if @petition.prohibited?
      redirect_to petition_manage_path(@petition)
    end
  end

  def verify_petition_is_launched
    unless @petition.launched?
      redirect_to launch_petition_path(@petition), alert: "Petition must be launched before it can be managed."
    end
  end

end