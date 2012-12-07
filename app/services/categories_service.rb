class CategoriesService < ApplicationService
  klass Category
  
  set_callback :create,   :after,  :notify_external_system_on_create,  :if => "!halted && value"
  set_callback :update,   :after,  :notify_external_system_on_update,  :if => "!halted && value"


  def notify_external_system_on_create
    category = current_object
    organisation = current_object.organisation

    OrgNotifier.new.delay.notify_category_creation(organisation: organisation, category: category)
  end

  def notify_external_system_on_update
    category = current_object
    organisation = current_object.organisation

    OrgNotifier.new.delay.notify_category_update(organisation: organisation, category: category)
  end
end