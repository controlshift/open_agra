class Org::Petitions::SignaturesController < Org::OrgController
  before_filter :load_and_authorize_petition

  def index
    @signatures = @petition.signatures.paginate page: params[:page], order: 'created_at DESC'
  end

  def email
    signature = Signature.lookup params[:email], @petition
    if signature
      @signatures = [signature]
      render 'index'
    else
      redirect_to org_petition_signatures_path(@petition), alert: "Address Not Found"
    end
  end

  def unsubscribe
    @signature = Signature.find_by_id(params[:id])
    @unsubscribe = Unsubscribe.new(:signature => @signature, :petition => @petition, :email => @signature.email)

    if @unsubscribe.unsubscribe
      flash[:notice] = "You have successfully unsubscribed #{@signature.email} from #{@petition.title}."
    else
      flash[:notice] = "Unable to unsubscribe #{@signature.email}"
    end
    redirect_to params[:redirect_to] || org_petition_signatures_path(@petition)
  end

  private
  def load_and_authorize_petition
    @petition = Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end
end