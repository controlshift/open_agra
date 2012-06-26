class Admin::PetitionsController < Admin::AdminController
  helper_method :sort_column, :sort_direction

  def search
    begin
      @query = Queries::Petitions::AdminQuery.new(page: params[:page], search_term: params[:query])
      if @query.valid?
        @query.execute!
      end

    rescue Errno::ECONNREFUSED
      flash.now.alert = "Failed to search. Please contact technical support."
    end
  end

  def index
    @list  = Queries::Petitions::List.new(sort_direction: params[:direction], sort_column: params[:sort], page: params[:page])
  end

  def hot
    @petitions = Petition.hot(Organisation.all)
  end
end
