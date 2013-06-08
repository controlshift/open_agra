class NotifyCategoryUpdateWorker < NotifyWorker
  def perform(organisation_id, category_id)
    organisation = Organisation.find(organisation_id)
    category = Category.find(category_id)
    notify(:notify_category_update, organisation: organisation, category: category)
  end
end