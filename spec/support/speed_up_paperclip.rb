module Paperclip
  class Geometry
    def self.from_file file
      parse("100x100")
    end
  end
  class Thumbnail
    def make
      src = File.join(Rails.root, 'spec', 'fixtures', "tiny_image.jpg")
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      FileUtils.cp(src, dst.path)
      return dst
    end
  end
end