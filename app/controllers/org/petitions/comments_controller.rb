class Org::Petitions::CommentsController < Org::OrgController
  before_filter :load_and_authorize_petition
  before_filter :load_comment, only: [:approve, :remove]
  before_filter :load_comments

  def index
  end

  def approve 
    @comment.approved = true
    CommentsService.new.save(@comment)
    render :reload_all_comments, layout: false, formats: :js
  end

  def remove
    @comment.approved = false
    CommentsService.new.save(@comment)
    render :reload_all_comments, layout: false, formats: :js
  end

  private

  def load_comments
    @comments = @petition.comments.paginate page: params[:page], per_page: 30, order: 'created_at DESC'
  end

  def load_and_authorize_petition
    @petition = Petition.find_by_slug params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end

  def load_comment
    @comment = Comment.find(params[:id])
    raise ActiveRecord::RecordNotFound if @comment.signature.petition != @petition
    raise ActiveRecord::RecordNotFound if @comment.nil?
  end
end