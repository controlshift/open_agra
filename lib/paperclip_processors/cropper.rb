module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      target = @attachment.instance
      if target.cropping?
        " -crop '#{target.crop_whxy}' " + super.join(' ')
      else
        super
      end
    end
  end
end

