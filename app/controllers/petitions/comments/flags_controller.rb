class Petitions::Comments::FlagsController < ApplicationController
  before_filter :load_petition
  before_filter :load_comment

  skip_before_filter :authenticate_user!

  def create
    if simple_captcha_valid?
      @comment.flagged_at = Time.now
      @comment.flagged_by = current_user
      CommentsService.new.save(@comment)
      render :create_success, layout: false, formats: :js
    else
      render :create_error, layout: false, formats: :js
    end
  end

  def new
    render layout: false
  end

  def load_comment
    @comment = @petition.comments.find(params[:comment_id])
  end

  def load_petition
    @petition = Petition.find_by_slug(params[:petition_id])

    raise ActiveRecord::RecordNotFound if @petition.nil?
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end