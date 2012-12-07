require 'spec_helper'

describe CachedUrlController do
  let(:response_body) do
      <<-json_string
jQuery18202026190939359367_1351783955288([{"provider_url": "http://www.youtube.com/", "description": "MIT Gangnam Style (MIT \uac15\ub0a8\uc2a4\ud0c0\uc77c \ud328\ub7ec\ub514), Music by PSY + MIT Logs - secondary link: http://mobileyt.com/21678457.php - FACEBOOK: http://www.facebook.com/MIT.GangnamStyle Inspired by PSY's GANGNAM STYLE: http://youtu.be/9bZkp7q19f0 Directed by Eddie Ha '13 Edited by Eddie Ha '13 Produced by Ingwon Chae '14 MIT PSY - Richard Yoon '13 and the Gangnam Style", "title": "MIT Gangnam Style (MIT \uac15\ub0a8\uc2a4\ud0c0\uc77c)", "url": "http://www.youtube.com/watch?v=lJtHNEDnrnY", "html": "<iframe width=\"460\" height=\"259\" src=\"http://www.youtube.com/embed/lJtHNEDnrnY?wmode=opaque&fs=1&feature=oembed\" frameborder=\"0\" allowfullscreen></iframe>", "author_name": "MIT GangnamStyle", "height": 259, "width": 460, "thumbnail_url": "http://i1.ytimg.com/vi/lJtHNEDnrnY/hqdefault.jpg", "thumbnail_width": 480, "version": "1.0", "provider_name": "YouTube", "type": "video", "thumbnail_height": 360, "author_url": "http://www.youtube.com/channel/UCMuvEJwKT-oRhDRbHxpd1gQ"}])
      json_string
  end

  describe "adjust_callback" do
    it "should replace the existing jQuery value" do
      controller.send(:adjust_callback, response_body, "new_callback").should start_with("new_callback(")
    end
  end

  describe "invalid params" do
    it "should return 404" do
      get :retrieve, { "uri"=>"1/oembed" }
      response.should be_not_found
    end
  end

  context "with a subbed http request" do
    before(:each) do
      controller.should_receive(:http_get).once.and_return(response_body)
    end

    after(:each) do
      Rails.cache.clear
    end

    describe "#retrieve" do
      it "should return a response with an adjusted callback" do

        get :retrieve, {"callback"=>"foo", "urls"=>"http://www.youtube.com/watch?v=lJtHNEDnrnY", "maxwidth"=>"460", "wmode"=>"opaque", "_"=>"1351783956530", "uri"=>"1/oembed"}
        response.should be_success
        response.body.should start_with("foo(")
        response.body.should =~ /MIT/
      end

      it "should use the cache to make only a single GET request, even when called twice." do
        2.times do
          get :retrieve, {"callback"=>"foo", "urls"=>"http://www.youtube.com/watch?v=lJtHNEDnrnY", "maxwidth"=>"460", "wmode"=>"opaque", "_"=>"1351783956530", "uri"=>"1/oembed"}
        end
      end
    end
  end
end
