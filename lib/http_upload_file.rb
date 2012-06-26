class HttpUploadFile < ::Tempfile
  attr_accessor :original_filename, :content_type
  
  def initialize(filename, content_type = nil)
    super(SecureRandom.hex)
    @original_filename = filename
    @content_type = content_type if content_type.present?
  end
  
  def write_data(data)
    File.open(self.path, 'wb') do |f|
      f.write data
    end
  end
end