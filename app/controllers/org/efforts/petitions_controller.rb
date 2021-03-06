class Org::Efforts::PetitionsController < Org::OrgController
  before_filter :load_and_authorize

  def check
    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
    if @petition
      render json: @petition.to_json(only: [:slug, :title]), status: :ok
    else
      render json: { message: t('controllers.org.petition.not_found') }, status: :not_acceptable
    end
  end

  def move
    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
    @petition.effort = @effort
    @petition.save!
    render json: @petition.to_json(only: [:slug, :title]), status: :ok
  end

  def note
    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
    if @petition
      raise ActiveRecord::RecordNotFound if @petition.effort != @effort
      raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    end

    @petition.admin_notes = params[:petition][:admin_notes]
    flash[:notice] = t('controllers.org.petition.note_saved') if @petition.save
    redirect_to org_effort_leader_path(@effort, @petition)
  end

  private
  def load_and_authorize
    @effort = Effort.find_by_slug! params[:effort_id]
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation

    authorize_or_redirect! :manage, @effort
  end
end