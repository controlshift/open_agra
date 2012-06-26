# == Schema Information
#
# Table name: contents
#
#  id              :integer         not null, primary key
#  organisation_id :integer
#  slug            :string(255)
#  name            :string(255)
#  category        :string(255)
#  body            :text
#  filter          :string(255)     default("none")
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'spec_helper'

describe Content do
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:filter) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:category) }

  context "a stubbed organisation" do
    before(:each) do
      @organisation = mock()
      @organisation.stub(:id).and_return(1)
      @organisation.stub(:slug).and_return('banana-slug')
    end

    describe ".content_for" do
      context "a content mock" do
        before(:each) do
          @content = mock()
          @content.stub(:render).and_return('content')
          @content.stub(:updated_at).and_return(Time.now)
        end

        it "should load the organisation text if it is present" do
          Content.should_receive(:find_by_slug_and_organisation_id).with('slug', @organisation.id).and_return(@content)
          Content.should_not_receive(:find_by_slug_and_organisation_id).with('slug', nil)

          Content.content_for('slug', @organisation).should == 'content'
        end

        it "should fall back on the default" do
          Content.should_receive(:find_by_slug_and_organisation_id).with('slug', @organisation.id).and_return(nil)
          Content.should_receive(:find_by_slug_and_organisation_id).with('slug', nil).and_return(@content)

          Content.content_for('slug', @organisation).should == 'content'
        end

        it "should display the slug if no content found" do
          Content.should_receive(:find_by_slug_and_organisation_id).with('slug', @organisation.id).and_return(nil)
          Content.should_receive(:find_by_slug_and_organisation_id).with('slug', nil).and_return(nil)

          Content.content_for('slug', @organisation).should == '__slug__'
        end

      end
    end
  end

  describe "#render" do
    before(:each) do
      @content = Content.new
    end

    it "should not modify raw content" do
      @content.filter = 'none'
      @content.body = 'raw content'
      @content.render.should == 'raw content'
    end

    it "should render textile" do
textile = <<-textile_string
h2. A title
textile_string
      @content.filter = 'textile'
      @content.body = textile
      @content.render.should == '<h2>A title</h2>'
    end

    it "should render liquid" do
      @content.filter = 'liquid'
      @content.body = "{{petition.title}}"
      petition = Factory.build(:petition)
      @content.render('petition' => petition).should == petition.title
    end

    it "should let you use url helpers" do
      petition = Factory(:petition, slug: 'foo', :organisation => Factory(:organisation, :host => 'foo.com'))
      @content.filter = 'liquid'
      @content.body = "{{ 'my petition' | link_to_petition:petition }}"
      @content.render('petition' => petition).should == "<a href=\"http://foo.com/petitions/foo\" title=\"my petition\">my petition</a>"
    end

    it "should let you use the petition tags" do
      petition = Factory(:petition, slug: 'foo', :organisation => Factory(:organisation, :host => 'foo.com'))
      @content.filter = 'liquid'
      @content.body = "{% petition_url %}"
      @content.render('petition' => petition).should == "http://foo.com/petitions/foo"
    end


    it "should let you use the petition manage tag" do
      petition = Factory(:petition, slug: 'foo', :organisation => Factory(:organisation, :host => 'foo.com'))
      @content.filter = 'liquid'
      @content.body = "{% petition_manage_url %}"
      @content.render('petition' => petition).should == "http://foo.com/petitions/foo/manage"
    end
  end
  
  describe "#export" do
    let(:organisation) { Factory(:organisation) }
    
    it "should return contents for organisation" do
      content = Factory(:content, organisation: organisation)
      other_content = Factory(:content, organisation: Factory(:organisation))
      contents = Content.export(organisation.id)
      contents.count.should == 1
      contents.first.should == content.to_hash
    end
    
    it "should return contents for slugs" do
      content1 = Factory(:content, slug: "slug1", organisation: organisation)
      content2 = Factory(:content, slug: "slug2", organisation: organisation)
      content3 = Factory(:content, slug: "slug3", organisation: organisation)
      contents = Content.export(organisation.id, ["slug1", "slug3"])
      contents.count.should == 2
      contents.should include content1.to_hash, content3.to_hash
    end
  end
  
  describe "#import" do
    let(:organisation) { Factory(:organisation) }
    
    before :each do
      @content = Factory(:content, slug: "slug", organisation: organisation)
    end
    
    it "should update existing content if exists" do
      content_params = [Factory.attributes_for(:content, slug: "slug", name: "name", category: "Home", body: "body", filter: "none")]
      Content.import(organisation.id, content_params)
      @content.reload
      @content.name.should == "name"
      @content.category.should == "Home"
      @content.body.should == "body"
      @content.filter.should == "none"
    end
    
    it "should create new content if not exists" do
      content_params = [Factory.attributes_for(:content, slug: "slug_new", name: "name", category: "Footer", body: "body", filter: "textile")]
      Content.import(organisation.id, content_params)
      new_content = Content.find_by_slug_and_organisation_id("slug_new", organisation.id)
      new_content.name.should == "name"
      new_content.category.should == "Footer"
      new_content.body.should == "body"
      new_content.filter.should == "textile"
    end
  end
end
