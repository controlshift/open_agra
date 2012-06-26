require "spec_helper"

describe "Liquid::TemplateCache" do
  it "should stuff parsed templates into a cache" do
    # warm cache
    Liquid::TemplateCache.parse('foo', 'bar')

    # should not parse again after the cache has been warmed.
    Liquid::Template.should_not_receive(:parse)
    Liquid::TemplateCache.parse('foo', 'bar')
  end
end