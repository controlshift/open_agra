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

class Content < ActiveRecord::Base
  validates_presence_of :slug, :body, :filter, :name, :category
  FILTER_TYPES = ['textile', 'none', 'liquid']
  validates_inclusion_of :filter, :in => FILTER_TYPES
  
  CATEGORIES = ['Home', 'Footer', 'Petitions', 'Petition Manage', 'Petition Landing', 'Email', 'Social']
  validates_inclusion_of :category, :in => CATEGORIES
  
  validates_uniqueness_of :slug, :scope => 'organisation_id'

  belongs_to :organisation
  attr_protected :organisation_id

  def self.for_slug_and_organisation(slug, organisation)
    Content.find_by_slug_and_organisation_id(slug, organisation.id) || Content.find_by_slug_and_organisation_id(slug, nil)
  end

  #if there is not client specific content, fallback on default
  def self.content_for(slug, organisation, context = {})
    content =  for_slug_and_organisation(slug, organisation)
    if content
      content.render(context, "#{organisation.slug}#{slug}#{content.updated_at.to_i}")
    else
      "__#{slug}__"
    end
  end

  def to_param
    return slug
  end

  def render(context = {}, key = nil)
    if filter == 'liquid'
      rendered = Liquid::TemplateCache.render(context, key, body)
    elsif filter == 'textile'
      rendered = RedCloth.new(body).to_html
    else
      rendered = body
    end
    rendered.html_safe
  end

  def to_hash
    { slug: slug, name: name, category: category, body: body, filter: filter }
  end

  def self.export(organisation_id, slugs = nil)
    if slugs.blank?
      contents = self.where(organisation_id: organisation_id)
    else
      contents = self.where(organisation_id: organisation_id, slug: slugs)
    end
    contents.map { |c| c.to_hash }
  end
  
  def self.import(organisation_id, content_params)
    content_params.map(&:with_indifferent_access).each do |params|
      slug = params[:slug]
      next if slug.blank?
      
      existing_content = find_by_slug_and_organisation_id(slug, organisation_id)
      if existing_content.nil?
        content = Content.new(params)
        content.organisation_id = organisation_id
        content.save!
      else
        existing_content.name = params[:name]
        existing_content.category = params[:category]
        existing_content.body = params[:body]
        existing_content.filter = params[:filter]
        existing_content.save!
      end
    end
  end
end
