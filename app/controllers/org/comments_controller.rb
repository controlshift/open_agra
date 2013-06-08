class Org::CommentsController < Org::OrgController

  before_filter :load_comment, only: [:approve, :remove]
  before_filter :load_comments

  def index
  end

  def approve 
    @comment.approved = true
    CommentsService.new.save(@comment)
    render :reload_flagged_comments, layout: false, formats: :js
  end

  def remove
    @comment.approved = false
    CommentsService.new.save(@comment)
    render :reload_flagged_comments, layout: false, formats: :js
  end

private
  def load_comments
    @comments = Comment.awaiting_moderation(current_organisation.id).paginate page: params[:page], per_page: 30
  end

  def load_comment
    @comment = Comment.find(params[:id])
    raise ActiveRecord::RecordNotFound if @comment.signature.petition.organisation != current_organisation
    raise ActiveRecord::RecordNotFound if @comment.nil?
  end
end