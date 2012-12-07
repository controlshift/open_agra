class Petitions::PetitionFlagsController < ApplicationController

  before_filter :load_petition
  skip_before_filter :authenticate_user!, only: [:create]

  def create
    @flag = PetitionFlag.new
    @flag.petition = @petition
    @flag.user = current_user unless current_user.nil?
    @flag.ip_address = request.remote_ip
    @flag.reason = params[:reason]

    if @flag.save
      threshold = Agra::Application.config.flagged_petitions_threshold
      PetitionFlagMailer.delay.notify_organisation_of_flagged_petition(@petition) if @petition.flags.count == 1 || @petition.flags.count == threshold
      respond_to do |format|
        format.html { redirect_to petition_path(@petition), notice: "The petition has been flagged." }
        format.json { render json: {notice: "The petition has been flagged."}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to petition_path(@petition), alert: "You have already flagged this petition." }
        format.json { render json: {notice: "You have already flagged this petition."}, status: :not_acceptable }
      end
    end
  end

  private

  def load_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end

end
