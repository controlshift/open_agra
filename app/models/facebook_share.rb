class FacebookShare
  # a very lightweight class to handle fb share spins on petition page load.
  extend Forwardable

  attr_reader  :variant
  attr_reader  :petition

  attr_accessor :variant_id

  def initialize(attrs = {})
    attrs.each do |key,value|
      if self.respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end

  def cache_key
    if variant
      variant.cache_key
    else
      'none'
    end
  end

  def variant=(v)
    @variant = v
    self.variant_id = variant.id
    self.petition = @variant.petition
    true
  end

  def petition=(p)
    @petition = p
  end

  def title
    variant ? variant.title : petition.title
  end

  def description
    variant ? variant.description : petition.why
  end

  def image
    variant ? variant.image : petition.image
  end

  def image_file_name
    variant ? variant.image_file_name : petition.image_file_name
  end

  def experiment
    return @experiment if defined?(@experiment)
    @experiment = Split::Experiment.find(experiment_key)
    if @experiment.nil?
      @experiment = Split::Experiment.new(experiment_key, alternatives: petition.share_variant_ids, algorithm: Split::Algorithms::Whiplash)
      @experiment.save
    end
    @experiment
  end

  def experiment_key
    "petition_fb_share_#{petition.id}"
  end

  def choose
    if petition && petition.facebook_share_variants.any?
      trial = Split::Trial.new(experiment: experiment)
      trial.choose
      v_id = trial.alternative.name
      self.variant= petition.facebook_share_variants.find{|variant| variant.id == v_id.to_i }
    end
  end

  def complete!
    Split::Trial.new(experiment: experiment, alternative: variant_id.to_s).complete!
  end

  def record!
    Split::Trial.new(experiment: experiment, alternative: variant_id.to_s).record!
  end

end