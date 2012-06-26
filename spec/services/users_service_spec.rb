require 'spec_helper'

describe UsersService do
  subject { UsersService.new }

  it { subject.should respond_to(:save) }
  it { subject.should respond_to(:update_attributes) }
end