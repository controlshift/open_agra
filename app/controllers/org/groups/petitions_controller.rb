class Org::Groups::PetitionsController < Org::OrgController
  before_filter :load_and_authorize

  def check
    if @petition
      render json: @petition.to_json(only: [:slug, :title]), status: :ok
    else
      render json: { message: "No petition found" }, status: :not_acceptable
    end
  end

  def move
    @petition.group = @group
    @petition.save!
    render json: @petition.to_json(only: [:slug, :title]), status: :ok
  end

  private
  def load_and_authorize
    @group = Group.find_by_slug! params[:group_id]
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation

    authorize_or_redirect! :manage, @group

    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
  end
end