module StoriesHelper
  def story_image(story, style=:hero)
    content_tag(:div, class: "petition-image") do
      unless story.image_file_name.blank?
        image_tag(story.image.url(style), title: story.title, alt: story.title)
      else
        image_tag("story-image-placeholder.png")
      end
    end
  end
end