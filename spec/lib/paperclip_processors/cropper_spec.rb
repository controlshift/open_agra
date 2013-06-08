require 'spec_helper'

describe "Paperclip::Cropper" do
  it "should return the original command if no cropping" do
  	file = File.new(File.join(Rails.root, 'spec', 'fixtures', "tiny_image.jpg"))
  	cropper = Paperclip.processor(:cropper).new(file, :geometry => "32x32<")
  	cropper.instance_variable_set(:@attachment, mock(instance: mock(cropping?: false)))
  	cropper.transformation_command.should == ["-resize", "\"32x32<\""]
  end
  it "should return the original command along with crop command if cropping" do
  	file = File.new(File.join(Rails.root, 'spec', 'fixtures', "tiny_image.jpg"))
  	cropper = Paperclip.processor(:cropper).new(file, :geometry => "32x32<")
  	cropper.instance_variable_set(:@attachment, mock(instance: mock(cropping?: true, crop_whxy: '300x300+300+300')))
  	cropper.transformation_command.should == " -crop '300x300+300+300' -resize \"32x32<\""
  end
end