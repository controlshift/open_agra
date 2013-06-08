module UnsubscribeHelper
  def blast_email_unsubscribe_url(email, options = {})
    if email.is_a?(PetitionBlastEmail)
      unsubscribing_petition_signature_url(email.petition, "___token___", options)
    elsif email.is_a?(GroupBlastEmail)
      group_unsubscribe_url(email.group, "___token___", options)
    else
      raise "do not know how to unsubscribe"
    end
  end
end