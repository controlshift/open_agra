class Org::Petitions::NoteController < Org::OrgController
  
  def update
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation

    @petition.admin_notes = params[:admin_notes]
    if PetitionsService.new.save(@petition)
      render json: {}, status: :ok 
    else
       render json: {message: "Invalid input. Your note cannot be saved."}, status: :not_acceptable 
    end
  end
end
    