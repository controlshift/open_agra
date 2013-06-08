class Org::ContentsController < Org::OrgController

  def index
    if params[:category]
      if Content::CATEGORIES.include? params[:category]
        @contents = Content.text.where(organisation_id: nil, category: params[:category])
      else
        flash[:alert] = t('controllers.org.content.unknown_category')
        redirect_to org_contents_path
      end
    end
  end

  def new
    old_content = Content.text.where(slug: params[:id], organisation_id: nil).first
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
      flash[:alert] = t('controllers.org.content.error_save')
      render :new
    end
  end

  def edit
    @content = Content.text.where(slug: params[:id], organisation_id: current_organisation.id).first
    if @content.nil?
      @content = Content.text.where(slug: params[:id], organisation_id: nil).first
      redirect_to new_org_content_path(:id => @content.slug)
    else
      render :edit
    end
  end

  def update
    @content = Content.text.where(slug: params[:content][:slug], organisation_id: current_organisation.id).first
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
      redirect_to migrate_org_contents_path, alert: t('controllers.org.content.error_export')
    else
      data = contents.to_json
      send_data data, filename: "#{request.host}_content_#{Time.now.strftime("%Y%m%d%H%M")}.json", type: "application/json"
    end
  end
  
  def import
    upload = params[:upload]
    content_params = JSON.parse(upload.read)
    Content.import(current_organisation.id, content_params)
    redirect_to migrate_org_contents_path, notice: t('controllers.org.content.success_import')
  rescue Exception => e
    redirect_to migrate_org_contents_path, alert: e.message
  end

end
