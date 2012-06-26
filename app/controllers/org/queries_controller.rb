class Org::QueriesController < Org::OrgController
  def new
    @org_query = Queries::OrgQuery.new(organisation: current_organisation)
  end

  def create
    @org_query = Queries::OrgQuery.new params[:queries_org_query]
    @org_query.organisation = current_organisation
    begin
      @org_query.execute
    rescue Exception => e
      flash.now.alert = e.message
    end
    render :new
  end
end
