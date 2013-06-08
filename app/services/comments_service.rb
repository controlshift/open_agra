class CommentsService < ApplicationService
  klass Comment

  set_callback :update, :after, :update_petition_comments_count, :if => "!halted && value"
  set_callback :create, :after, :increment_count_if_not_profane, :if => "!halted && value"
  set_callback :save,   :after, :touch_comments_updated_at, :if => "!halted && value"
  def update_petition_comments_count
    petition = current_object.signature.petition
    Rails.cache.write(petition.comments_count_key, petition.comments_size, raw: true)
    true
  end

  def increment_count_if_not_profane
    petition = current_object.signature.petition
    update_petition_comments_count and return if Rails.cache.read(petition.comments_count_key).blank?

    Rails.cache.increment(petition.comments_count_key, 1,  raw: true) if current_object.approved.nil?
    true
  end

  def touch_comments_updated_at
    # we aren't using AR touch here to prevent changing petition#updated_at
    Petition.update_all({:comments_updated_at => Time.now}, {id: current_object.signature.petition_id})
  end
end
