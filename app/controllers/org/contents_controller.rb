class Org::ContentsController < Org::OrgController

  def index
    if params[:category]
      if Content::CATEGORIES.include? params[:category]
        @contents = Content.where(organisation_id: nil, category: params[:category])
      else
        flash[:alert] = 'Unknown category'
        redirect_to org_contents_path
      end
    end
  end

  def new
    old_content = Content.find_by_slug_and_organisation_id(params[:id], nil)
    @content = Content.new :slug => old_content.slug,
                           :body => old_content.body,
                           :filter => old_content.filter,
                           :name => old_content.name,
                           :category => old_content.category
    @content.organisation = current_organisation
  end

  def create
    @content = Content.new params[:content].except(:organisation_id)
    @content.organisation = current_organisation
    if @content.save
      redirect_to org_contents_path
    else
      flash[:alert] = 'There was a problem saving your content.'
      render :new
    end
  end

  def edit
    @content = Content.find_by_slug_and_organisation_id(params[:id], current_organisation.id)
    if @content.nil?
      @content = Content.find_by_slug_and_organisation_id(params[:id], nil)
      redirect_to new_org_content_path(:id => @content.slug)
    else
      render :edit
    end
  end

  def update
    @content = Content.find_by_slug_and_organisation_id(params[:content][:slug], current_organisation.id)
    if @content.update_attributes params[:content].except(:organisation_id)
      redirect_to org_contents_path
    else
      render :edit
    end
  end
  
  def migrate
  end
  
  def export
    contents = Content.export(current_organisation.id, params[:slug])
    if contents.blank?
      redirect_to migrate_org_contents_path, alert: "No customised content to download."
    else
      data = contents.to_json
      send_data data, filename: "#{request.host}_content_#{Time.now.strftime("%Y%m%d%H%M")}.json", type: "application/json"
    end
  end
  
  def import
    upload = params[:upload]
    content_params = JSON.parse(upload.read)
    Content.import(current_organisation.id, content_params)
    redirect_to migrate_org_contents_path, notice: "Content is imported successfully."
  rescue Exception => e
    redirect_to migrate_org_contents_path, alert: e.message
  end

end
