class Org::Petitions::FacebookShareVariantsController < Org::OrgController
  before_filter :load_and_authorize_petition
  before_filter :load_variant, only: [:edit, :update, :destroy]

  def index
    @share_variants = @petition.facebook_share_variants
  end

  def new
    @share_variant = FacebookShareVariant.new
    @share_variant.petition = @petition
  end

  def create
    @share_variant = FacebookShareVariant.new params[:facebook_share_variant]
    @share_variant.petition = @petition
    if @share_variant.save
      redirect_to org_petition_facebook_share_variants_path(@petition)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @share_variant.update_attributes(params[:facebook_share_variant])
      redirect_to org_petition_facebook_share_variants_path(@petition)
    else
      render :edit
    end
  end

  def destroy
    @share_variant.destroy
    flash[:notice] = t('controllers.org.petitions.facebook_share_variant.success_delete', value: @share_variant.title)
    redirect_to org_petition_facebook_share_variants_path(@petition)
  end

  private
  def load_and_authorize_petition
    @petition= Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end

  def load_variant
    @share_variant = FacebookShareVariant.find params[:id]
    raise ActiveRecord::RecordNotFound if @share_variant.petition != @petition
  end

end