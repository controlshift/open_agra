class Org::CategoriesController < Org::OrgController
  before_filter :load_and_authorize_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.where(:organisation_id => current_organisation.id)
                    .order("name")
  end
  
  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    @category.organisation = current_organisation
    if CategoriesService.new.save(@category)
      redirect_to org_categories_path, notice: "Category #{@category.name} has been created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if CategoriesService.new.update_attributes(@category, params[:category])
      redirect_to org_categories_path, notice: "Category #{@category.name} has been updated."
    else
      render :edit
    end
  end
  
  def destroy
    @category.destroy
    redirect_to org_categories_path, notice: 'Category has been deleted.'
  end
  
  private
  
  def load_and_authorize_category
    @category = Category.find_by_slug! params[:id]
    authorize_or_redirect! :manage, @category
    raise ActiveRecord::RecordNotFound if @category.organisation != current_organisation
  end
end
