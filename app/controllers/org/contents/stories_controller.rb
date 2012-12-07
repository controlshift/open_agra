class Org::Contents::StoriesController < Org::OrgController
  before_filter :load_and_authorize_story, only: [:edit, :update, :show]

  def index
    @stories = Story.where(:organisation_id => current_organisation.id)
                    .order("created_at DESC")
                    .paginate(page: params[:page])
    
    render :index
  end
  
  def show
  end
  
  def new
    @story = Story.new
  end

  def create
    @story = Story.new params[:story]
    @story.organisation = current_organisation
    if @story.save
      redirect_to org_contents_story_path(@story)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @story.update_attributes(params[:story])
      redirect_to org_contents_story_path(@story)
    else
      render :edit
    end
  end
  
  private
  
  def load_and_authorize_story
    @story = Story.find_by_id! params[:id]
    raise ActiveRecord::RecordNotFound if @story.organisation != current_organisation
    authorize_or_redirect! :manage, @story
  end
end