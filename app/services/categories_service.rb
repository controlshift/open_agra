class CategoriesService < ApplicationService
  klass Category
  
  set_callback :save,   :after,  :notify_external_system,  :if => "!halted && value"
  
  def notify_external_system
    category = current_object
    organisation = current_object.organisation

    OrgNotifier.new.delay.notify_category_creation(organisation: organisation, category: category)
  end
end