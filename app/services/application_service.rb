class ApplicationService

  include ActiveSupport::Callbacks
  define_callbacks :save, :create, :update,
                   :terminator => "result == false"

  def initialize
  end


  class << self
    # Attaches the observer to the supplied model classes.
    def klass(*model)
      @@klass = model
      define_method(:current_klass) { @@klass }
    end
  end

  def current_object
    @obj
  end

  def current_object=(obj)
    @obj = obj
  end

  def save(obj)
    @obj = obj
    run_callbacks :save do
      if @obj.new_record?
        result = create
      else
        result = update
      end
      result
    end
  end

  def update_attributes(obj, params)
    @obj = obj
    @obj.assign_attributes(params)
    run_callbacks :save do
      run_callbacks :update do
         @obj.save
      end
    end
  end

  private

  def create
    run_callbacks :create do
      @obj.save
    end
  end

  def update
    run_callbacks :update do
      @obj.save
    end
  end


end