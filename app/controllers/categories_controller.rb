class CategoriesController < ApplicationController
  skip_before_filter :authenticate_user!, :all

  def index
    @query = Queries::Petitions::CategoryQuery.new(page: params[:page], organisation: current_organisation)
    @query.execute!
  end

  def show
    @category = Category.find_by_slug!(params[:id])
    @query = Queries::Petitions::CategoryQuery.new(page: params[:page],
                                                   organisation: current_organisation,
                                                   category: @category)
    @query.execute!

    render :index
  end
end
