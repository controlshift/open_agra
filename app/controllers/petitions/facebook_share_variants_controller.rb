class Petitions::FacebookShareVariantsController < ApplicationController
  before_filter :load_and_authorize_variant

  def show
    share = FacebookShare.new(variant: @variant)
    if has_facebook_user_agent?
      render layout: false
    else
      share.complete!
      redirect_to @petition
    end
  end

  # records facebook share button initiation.
  def update
    share = FacebookShare.new(variant: @variant)
    share.record!
    render json: {status: 'recorded'}
  end

  private
  def load_and_authorize_variant
    @petition= Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation

    @variant = @petition.facebook_share_variants.where(id: params[:id]).first!
  end

end