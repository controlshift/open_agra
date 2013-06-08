class Org::Petitions::NoteController < Org::OrgController
  
  def update
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation

    @petition.admin_notes = params[:petition][:admin_notes]
    respond_to do |format|
      if PetitionsService.new.save(@petition)
        flash[:notice] = t('controllers.org.petition.note_saved')

        format.js { render json: {}, status: :ok }
        format.html do
          flash[:notice] = t('controllers.org.petition.note_saved')
          redirect_to org_petition_path(@petition)
        end
      else
        format.js { render json: {message: t('controller.org.petitions.note.invalid_input')}, status: :not_acceptable }
        format.html do
          flash[:notice] = t('controller.org.petitions.note.error_save')
          redirect_to org_petition_path(@petition)
        end
      end
    end
  end
end
    