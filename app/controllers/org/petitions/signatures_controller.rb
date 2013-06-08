class Org::Petitions::SignaturesController < Org::OrgController
  before_filter :load_and_authorize_petition

  def index
    respond_to do | format |
      format.html do
        @signatures = @petition.signatures.paginate page: params[:page], order: 'created_at DESC'
      end

      format.csv do
        streaming_csv(Queries::Exports::AdminPetitionSignaturesExport.new(petition_id: @petition.id, organisation: current_organisation))
      end
    end
  end

  def email
    signature = Signature.lookup params[:email], @petition
    if signature
      @signatures = [signature]
      render 'index'
    else
      redirect_to org_petition_signatures_path(@petition), alert: t('errors.messages.address_not_found')
    end
  end

  def unsubscribe
    @signature = Signature.find_by_id(params[:id])
    @unsubscribe = Unsubscribe.new(:signature => @signature, :petition => @petition, :email => @signature.email)

    if @unsubscribe.unsubscribe
      flash[:notice] = t('controllers.org.petitions.signature.success_unsubscribe', {email: @signature.email, petition: @petition.title})
    else
      flash[:notice] = t('controllers.org.petitions.signature.error_unsubscribe', email: @signature.email)
    end
    redirect_to params[:redirect_to] || org_petition_signatures_path(@petition)
  end

  def destroy
    @signature = Signature.find_by_id(params[:id])

    if SignaturesService.new.delete(@signature)
      flash[:notice] = t('controllers.org.petitions.signature.success_destroy')
    else
      flash[:notice] = t('controllers.org.petitions.signature.error_destroy')
    end
    redirect_to org_petition_signatures_path(@petition)
  end

  private
  def load_and_authorize_petition
    @petition = Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end
end