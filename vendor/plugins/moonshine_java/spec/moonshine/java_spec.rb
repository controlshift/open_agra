require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

class JavaManifest < Moonshine::Manifest::Rails
  include Moonshine::Java
end

describe Moonshine::Java do
  before do
    @manifest = JavaManifest.new
  end

  describe "with no options" do
    before do
      @manifest.java
    end

    it "should install sun-java6-bin" do
      @manifest.should have_package('sun-java6-bin')
    end

    it "should have our defaults file" do
      @manifest.files['/etc/java-debconf-set-selections'].content.should =~ /sun-java6-bin/
    end
  end

  describe "with options" do
    before do
      @manifest.java(:package => 'openjdk-6-jre')
    end 

    it "should install other java packages" do
      @manifest.should have_package('openjdk-6-jre')
    end 

    it "should have our defaults file without sun-java6 flags" do
      @manifest.files['/etc/java-debconf-set-selections'].content.should_not =~ /sun-java6-bin/
    end
  end

  it "should be executable" do
    @manifest.should be_executable
  end
end
