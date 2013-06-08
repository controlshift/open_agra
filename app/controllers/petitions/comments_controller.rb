class Petitions::CommentsController < ApplicationController
  before_filter :load_petition
  before_filter :load_comment, only: [:like, :show]

  skip_before_filter :authenticate_user!

  def index
    @comment_start = params[:comment_start]
    @comments = @petition.recent_comments(@comment_start.to_i)
    if @comments.any?
      respond_to do | format |
        format.js { render :layout => false }
      end
    else
      render :text => t("controllers.petitions.view.comments_not_found")
    end
  end

  def show
    if @comment.hidden?
      render_not_found
    else
      render :show
    end
  end

  def create
    @comment = Comment.new(text: params[:comment][:text])
    if Obscenity.profane?(@comment.text)
      @comment.flagged_at = Time.now 
      @comment.approved = false
    end
    @signature = Signature.find_by_token! params[:id]
    @comment.signature = @signature
    if CommentsService.new.save(@comment)
      render :update_success, layout: false, formats: :js
    else
      render :update_failure, layout: false, formats: :js
    end
  end

  def like
    render nothing: true, status: :not_found and return if @comment.nil?
    @comment.update_attribute(:up_count, @comment.up_count + 1)
    render :like, layout: false, formats: :js
  end

  private
  
  def load_comment
    return if @petition.prohibited?
    @comment = @petition.comments.find(params[:id])
  end

  def load_petition
    @petition = Petition.find_by_slug(params[:petition_id])

    raise ActiveRecord::RecordNotFound if @petition.nil?
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end