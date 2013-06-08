class Org::Petitions::SettingsController < Org::OrgController
  before_filter :load_petition

  def show
  end

  def update
    @petition.redirect_to       = params[:petition][:redirect_to]
    @petition.show_progress_bar = params[:petition][:show_progress_bar]
    @petition.after_signature_redirect_url = params[:petition][:after_signature_redirect_url]
    @petition.save!
    redirect_to org_petition_path(@petition)
  end

  def load_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end