require 'active_support/concern'

module HasMember
  extend ActiveSupport::Concern

  included do
    before_save :find_or_create_member!
  end

  module ClassMethods

  end

  module InstanceMethods
    def find_or_create_member!
      if self.member.blank?
        m = Member.lookup(self.email, self.organisation)
        if m.blank?
          m = Member.create!(email: self.email, organisation: self.organisation)
        end
        self.member = m
      end
    end
  end
end
