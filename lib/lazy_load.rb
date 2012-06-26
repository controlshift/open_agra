class LazyLoad < Delegator
  def initialize(&block)
    @block = block
  end

  def __getobj__
    @delegate ||= @block.call
  end
end