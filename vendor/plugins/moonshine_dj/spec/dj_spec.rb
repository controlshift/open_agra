require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class DJManifest < Moonshine::Manifest::Rails
  include Moonshine::DJ
end

describe "A manifest with the DJ plugin" do
  before do
    @manifest = DJManifest.new
    @manifest.configure(:dj => {})
  end

  it "should be executable" do
    @manifest.should be_executable
  end

  describe "using the `dj` recipe" do
    before do
      @manifest.dj
    end

    it "should install the template" do
      dj_file = @manifest.files["/etc/god/#{@manifest.configuration[:application]}-dj.god"]['content']
      dj_file.should_not be_nil
      dj_file.should include("1.times do |num|")
      dj_file.should include("w.group    = '#{@manifest.configuration[:application]}-dj'")
      dj_file.should include("w.name     = \"#{@manifest.configuration[:application]}-dj")
    end
  end

  describe "configuring the `dj` recipe" do
    before do
      @manifest.configure(:dj => { :workers => 2})
      @manifest.dj
    end
    
    it "should install the template with configuration" do
      dj_file = @manifest.files["/etc/god/#{@manifest.configuration[:application]}-dj.god"]['content']
      dj_file.should_not be_nil
      dj_file.should include("2.times do |num|")
    end
  end
end
