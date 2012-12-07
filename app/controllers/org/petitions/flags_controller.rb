class Org::Petitions::FlagsController < Org::OrgController
  before_filter :load_and_authorize_petition

  def index
    @flags = @petition.flags.paginate page: params[:page], order: 'created_at DESC'
  end

  private
    def load_and_authorize_petition
      @petition= Petition.find_by_slug! params[:petition_id]
      raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
      authorize_or_redirect! :manage, @petition
    end
end