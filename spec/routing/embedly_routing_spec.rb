require 'spec_helper'

describe "embed.ly routing behavior" do
 it "should parse the embedly uri out of the URL" do
   { :get => "/cached_url/1/oembed?callback=jQuery18206144141563372841_1353510956567&urls=http%3A%2F%2Fwww.telegraph.co.uk%2Fnews%2F9669410%2FSAS-war-hero-jailed-after-betrayal.html&maxwidth=460&wmode=opaque&_=1353510957474" }.
     should route_to(
       :controller => "cached_url",
       :uri => "1/oembed",
       :action => "retrieve"
     )
 end
end