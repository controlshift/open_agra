module Liquid
  class AgraUrl < Liquid::Tag
    include Rails.application.routes.url_helpers

    def find_organisation

      if @context_hash['organisation'] && @context_hash['organisation'].respond_to?(:host)
        @context_hash['organisation']
      elsif @context_hash['petition'] && @context_hash['petition'].respond_to?(:organisation) && @context_hash['petition'].organisation.respond_to?(:host)
        @context_hash['petition'].organisation
      else
        nil
      end

    end

    def default_url_options
      organisation = find_organisation

      if organisation.present?
        {:host => organisation.host}
      else
        {}
      end
    end
  end

  class PetitionUrl < AgraUrl
    def initialize(tag_name, params, tokens)
      @tag_name = tag_name.intern
      super
    end

    def render(context)
      @context_hash = context.environments.first
      self.send(@tag_name, @context_hash['petition'])
    end
  end

  class FacebookShareUrl < AgraUrl
    def render(context)
      @context_hash = context.environments.first
      petition = @context_hash['petition']

      "http://www.facebook.com/sharer.php?u=#{CGI::escape(petition_url(petition, time: petition.updated_at.to_i))}"
    end
  end

  class TwitterShareUrl < AgraUrl
    def render(context)
      @context_hash = context.environments.first
      petition = @context_hash['petition']

      href = "https://twitter.com/share?"
      href << "url=#{petition_url(petition)}"
      href << "&via=#{petition.organisation.twitter_account_name}" if petition.organisation.twitter_account_name.present?
      href << "&text=#{CGI::escape('This cause is close to my heart - please sign:')}"
      href
    end
  end
end

Liquid::Template.register_tag('petition_url', Liquid::PetitionUrl)
Liquid::Template.register_tag('petition_manage_url', Liquid::PetitionUrl)
Liquid::Template.register_tag('facebook_share_url', Liquid::FacebookShareUrl)
Liquid::Template.register_tag('twitter_share_url', Liquid::TwitterShareUrl)
