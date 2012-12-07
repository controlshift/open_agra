class CategoriesController < ApplicationController
  skip_before_filter :authenticate_user!, :all

  def index
    @query = Queries::Petitions::CategoryQuery.new(page: params[:page], organisation: current_organisation)
    @query.execute!
    respond_to do |format|
      format.any(:html, :mobile) { render :index }
      format.json { render json: categories_list, callback: params[:callback] }
    end
  end

  def show
    @category = Category.find_by_slug!(params[:id])
    raise ActiveRecord::RecordNotFound if @category.organisation != current_organisation

    respond_to do |format|
      format.any(:html, :mobile) {
        category_petitions
        render :index
      }
      format.json {
        category_petitions({per_page: 50})
        render json: petition_list, callback: params[:callback]
      }
    end
  end

  private

  def category_petitions(options={})
    @query = Queries::Petitions::CategoryQuery.new(page: params[:page],
                                                   organisation: current_organisation,
                                                   category: @category)

    @query.per_page = options[:per_page] if options[:per_page]
    @query.execute!
  end

  def categories_list
    @query.categories.collect do |category|
      {category_name: category.name, category_count: category.petitions.size}
    end
  end

  def petition_list
    {
        current_page: @query.petitions.current_page,
        total_pages: @query.petitions.total_pages,
        previous_page: @query.petitions.previous_page,
        next_page: @query.petitions.next_page,
        name: @category.name,
        results:
            @query.petitions.collect do |petition|
              {title: petition.title,
               id: petition.id,
               url: petition_url(petition),
               slug: petition.slug,
               creator_name: petition.user.full_name,
               created_at: petition.created_at,
               last_signed_at: petition.signatures.last.created_at,
               signature_count: petition.cached_signatures_size,
               goal: petition.goal,
               target: petition.who,
               why: petition.why.truncate(200)}
            end
    }
  end
end
