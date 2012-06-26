class AddGetupUserVoiceToOrganisation < ActiveRecord::Migration
  def up
    organisation = Organisation.find_by_slug 'getup'
    if organisation
      organisation.uservoice_widget_link = 'widget.uservoice.com/tYlNedADzZJrMF3oYzYcFA.js'
      organisation.save
    end
  end

end
