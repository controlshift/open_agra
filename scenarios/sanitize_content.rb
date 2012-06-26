require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Sanitize content", :type => :request do
  before(:each) do
    @user = Factory(:user, organisation: @current_organisation)
    @petition = Factory(:petition, 
                        user: @user, 
                        organisation: @current_organisation, 
                        title: "<b>Bold Title</b>",
                        why: "<i>Why</i> with <script> alert('why') </script> tag.",
                        what: "<i>What</i> with <script> alert('what') </script> tag.",
                        who: "<i>Who</i> with <script> alert('who') </script> tag.",
                        delivery_details: "<i>Delivery</i> with <script> alert('delivery') </script> tag.")
    log_in(@user.email)
  end
  
  def asset_no_tag_or_script
    page.html.should_not include "<b>Bold Title</b>"
    page.html.should_not include "<script> alert('why') </script>"
    page.html.should_not include "<script> alert('what') </script>"
    page.html.should_not include "<script> alert('delivery') </script>"
  end
  
  it "should escape content on petition public page" do
    visit petition_path(@petition)

    asset_no_tag_or_script
    find("h1.title").native.inner_html.should include "&lt;b&gt;Bold Title&lt;/b&gt;"
    find("pre.what").native.inner_html.should include "&lt;i&gt;What&lt;/i&gt; with &lt;script&gt; alert('what') &lt;/script&gt; tag."
    find("pre.why").native.inner_html.should include "&lt;i&gt;Why&lt;/i&gt; with &lt;script&gt; alert('why') &lt;/script&gt; tag."
    find("pre.delivery").native.inner_html.should include "&lt;i&gt;Delivery&lt;/i&gt; with &lt;script&gt; alert('delivery') &lt;/script&gt; tag."
  end
  
  it "should escape content on petition launch page" do
    @petition.update_attribute(:launched, false)
    
    visit launch_petition_path(@petition)
    
    asset_no_tag_or_script
    find("h1").native.inner_html.should include "&lt;b&gt;Bold Title&lt;/b&gt;"
    find("pre.what").native.inner_html.should include "&lt;i&gt;What&lt;/i&gt; with &lt;script&gt; alert('what') &lt;/script&gt; tag."
    find("pre.why").native.inner_html.should include "&lt;i&gt;Why&lt;/i&gt; with &lt;script&gt; alert('why') &lt;/script&gt; tag."
  end
  
  it "should escape content on home page" do
    @petition.update_attribute(:admin_status, :awesome)
    
    visit root_path
    
    asset_no_tag_or_script
    find(".petition-title h3").native.inner_html.should include "&lt;b&gt;Bold Title&lt;/b&gt;"
    find(".petition-why").native.inner_html.should include "&lt;i&gt;Why&lt;/i&gt; with &lt;script&gt; alert('why') &lt;/script&gt; tag."
  end
  
  it "should escape share email content" do
    visit share_petition_path(@petition)
    
    asset_no_tag_or_script
    find("#body-field").native.inner_html.should include "&lt;b&gt;Bold Title&lt;/b&gt;"
    find("#body-field").native.inner_html.should include "&lt;i&gt;Why&lt;/i&gt; with &lt;script&gt; alert('why') &lt;/script&gt; tag."
  end
end