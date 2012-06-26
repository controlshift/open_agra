module Liquid
  class TemplateCache

    def self.render(context, key, body)
      parsed = parse(key, body)
      parsed.render(context)
    end

    def self.parse(key, body)
      if key == nil
        Liquid::Template.parse(body)
      else
        $liquid_cache_store.fetch(key) do
          Liquid::Template.parse(body)
        end
      end
    end
  end
end