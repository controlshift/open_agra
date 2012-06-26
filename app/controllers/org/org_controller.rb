class Org::OrgController < ApplicationController
  layout :set_layout
  before_filter { authorize_or_redirect! :manage, current_organisation}

  private
    def set_layout
      if request.headers['X-PJAX']
        'pjax'
      else
        "sidebar"
      end
    end

end
