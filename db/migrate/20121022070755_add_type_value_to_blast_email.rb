class AddTypeValueToBlastEmail < ActiveRecord::Migration
  def change
    BlastEmail.all.each do |e|
      type = e.petition.present? ? 'PetitionBlastEmail' : 'GroupBlastEmail'
      e.update_column :type, type
    end
  end
end
