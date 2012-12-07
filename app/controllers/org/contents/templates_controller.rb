class Org::Contents::TemplatesController < Org::OrgController

  def index
    @contents = Content.email_template.where(organisation_id: nil)
  end

  def new
    old_content = Content.email_template.where(slug: params[:id], organisation_id: nil).first
    @content = Content.new :slug => old_content.slug,
                           :body => old_content.body,
                           :filter => old_content.filter,
                           :name => old_content.name,
                           :category => old_content.category,
                           :kind  => old_content.kind
    @content.organisation = current_organisation
  end

  def create
    @content = Content.new params[:content].except(:organisation_id)
    @content.organisation = current_organisation
    if @content.save
      redirect_to org_contents_templates_path
    else
      flash[:alert] = 'There was a problem saving your content.'
      render :new
    end
  end

  def edit
    @content = Content.email_template.where(slug: params[:id], organisation_id: current_organisation.id).first
    if @content.nil?
      @content = Content.email_template.where(slug: params[:id], organisation_id: nil).first
      redirect_to new_org_contents_template_path(:id => @content.slug)
    else
      render :edit
    end
  end

  def update
    @content = Content.email_template.where(slug: params[:content][:slug], organisation_id: current_organisation.id).first
    if @content.update_attributes params[:content].except(:organisation_id)
      redirect_to org_contents_templates_path
    else
      render :edit
    end
  end
end
