require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe "A manifest with the Heartbeat plugin" do

  before do
    @manifest = HeartbeatManifest.new
    @manifest.configure :heartbeat => YAML.load(<<-EOF
---
:nodes:
  :haproxy1: 12.34.56.78
  :haproxy2: 12.34.56.79
:resources:
  :haproxy1: 12.34.56.80
  :haproxy2:
  - 12.34.56.81
  - haproxy
:password: sekret
:ping: 12.34.56.78
EOF
)
  end

  describe "in general" do
    before(:each) do
      @manifest.heartbeat
    end

    it "should be executable" do
      @manifest.should be_executable
    end

    it "should include the heartbeat package" do
      @manifest.packages.keys.should include 'heartbeat'
    end

    it "should include the heartbeat config directory" do
      @manifest.files.keys.should include '/etc/ha.d'
    end

    it "should include the trio of required heartbeat config files" do
      @manifest.files.keys.should include '/etc/ha.d/haresources'
      @manifest.files.keys.should include '/etc/ha.d/authkeys'
      @manifest.files.keys.should include '/etc/ha.d/ha.cf'
    end

    it "should include the password in the secured authkeys file" do
      @manifest.files['/etc/ha.d/authkeys'].content.should match /sekret/
      @manifest.files['/etc/ha.d/authkeys'].mode.should == '600'
    end

    it "should include haresources, one on each line" do
      @manifest.files['/etc/ha.d/haresources'].content.should match /haproxy1 12.34.56.80/
      @manifest.files['/etc/ha.d/haresources'].content.should match /haproxy2 12.34.56.81 haproxy/
      @manifest.files['/etc/ha.d/haresources'].content.split("\n").size.should == 2
    end

    describe "should include ha.cf" do
      it "with a correct node list" do
        @manifest.files['/etc/ha.d/ha.cf'].content.should match /node haproxy1/
        @manifest.files['/etc/ha.d/ha.cf'].content.should match /node haproxy2/
      end

      it "with auto_failback enabled" do
        @manifest.files['/etc/ha.d/ha.cf'].content.should match /auto_failback on/
      end

      it "with ipfail configured and the ping node setup" do
        @manifest.files['/etc/ha.d/ha.cf'].content.should match /respawn hacluster \/usr\/lib\/heartbeat\/ipfail/
        @manifest.files['/etc/ha.d/ha.cf'].content.should match /ping 12.34.56.78/
      end
    end

  end

  describe "on the primary node" do
    before(:each) do
      Facter.should_receive(:hostname).any_number_of_times.and_return('haproxy1')
      @manifest.heartbeat
    end

    it "ucast should be set to ping the secondary node" do
      @manifest.files['/etc/ha.d/ha.cf'].content.should match /ucast eth0 12.34.56.79/
    end
  end

  describe "on the secondary node" do
    before(:each) do
      Facter.should_receive(:hostname).any_number_of_times.and_return('haproxy2')
      @manifest.heartbeat
    end

    it "ucast should be set to ping the primary node" do
      @manifest.files['/etc/ha.d/ha.cf'].content.should match /ucast eth0 12.34.56.78/
    end
  end

end