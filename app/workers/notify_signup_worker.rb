class NotifySignupWorker < NotifyWorker

  def perform(organisation_id, petition_id, user_details_id, role)
    organisation = Organisation.find(organisation_id)
    petition = Petition.find(petition_id)
    if role == 'signer'
      user_details = Signature.find user_details_id
    else
      user_details = User.find user_details_id
    end

    notify(:notify_sign_up, organisation: organisation, petiton: petition, user_details: user_details, role: role)
  end

end

