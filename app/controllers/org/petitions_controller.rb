class Org::PetitionsController < Org::OrgController
  before_filter :load_and_authorize_petition, only: [:update, :show, :note, :redirect]
  helper_method :sort_column, :sort_direction

  def search
    begin
      @query = Queries::Petitions::AdminQuery.new(search_term: params[:query], organisation: current_organisation, page: params[:page])

      if @query.valid?
        @query.execute!
      end

    rescue Errno::ECONNREFUSED
      flash.now.alert = t('errors.messages.search')
    end

    render "admin/petitions/search"
  end

  def index
    @list = Queries::Petitions::List.new(sort_direction: params[:direction],
                                        sort_column:    params[:sort],
                                        page:           params[:page],
                                        conditions:     { organisation_id: current_organisation.id })
    render "admin/petitions/index"
  end

  def hot
    @petitions = Petition.hot([current_organisation])
    render "admin/petitions/hot"
  end


  def moderation_queue
    petition_awaiting_moderation = Petition.awaiting_moderation(current_organisation.id)
    @petitions = petition_awaiting_moderation.paginate page: params[:page]
    @num_of_new_petitions = petition_awaiting_moderation.where(admin_status: :unreviewed).count
    @num_of_edited_petitions = petition_awaiting_moderation.where(admin_status: [:edited, :edited_inappropriate]).count
  end

  def update
    @petition.admin_status = params[:petition][:admin_status]
    @petition.admin_reason = @petition.admin_status == :inappropriate ? params[:petition][:admin_reason] : nil

    if PetitionsService.new.save(@petition)
      next_petition = Petition.awaiting_moderation(current_organisation.id).first
      redirect_to petition_path(next_petition ? next_petition : @petition), notice: t('controllers.org.petition.success_update')
    else
      @signature = Signature.new(default_organisation_slug: current_organisation.slug)
      signature_attributes = current_user.signature_attributes(@signature)
      @signature.assign_attributes( signature_attributes )
      render 'petitions/view/show'
    end
  end

  def show
    @admins = @petition.admins.reject { |a| a == @petition.user }
  end

  def note
    @petition.admin_notes = params[:petition][:admin_notes]
    flash[:notice] = t('controllers.org.petition.note_saved') if @petition.save
    redirect_to org_petition_path(@petition)
  end

  private

  def load_and_authorize_petition
    @petition = Petition.find_by_slug!(params[:petition_id] || params[:id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize! :manage, @petition
    authorize! :manage, current_user
  end

end
