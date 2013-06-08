module Progress
  MILESTONES_GAPS = { "500"=>100, "1000"=>200, "10000"=>1000, "50000"=>5000, "100000"=>25000 }
  def goal
    MILESTONES_GAPS.each do |key, value|
      if cached_signatures_size < key.to_i
        return (cached_signatures_size + 1).round_to_nearest(value)
      end
    end
    return (cached_signatures_size + 1).round_to_nearest(100000)
  end

  def percent_to_goal
    cached_signatures_size * 100 / goal
  end

  def cached_signatures_size
    return @cached_signatures_size if defined?(@cached_signatures_size) # return immediately if we have already calculated this
    @cached_signatures_size = Rails.cache.fetch(signatures_count_key, raw: true) do
      signatures_size
    end
    @cached_signatures_size  = @cached_signatures_size.respond_to?(:value) ? @cached_signatures_size.value.to_i : @cached_signatures_size.to_i # we need to do this, because we store as raw in memcached.
  end

  def cached_comments_size
    return @cached_comments_size if defined?(@cached_comments_size)
    @cached_comments_size = Rails.cache.fetch(comments_count_key, raw: true) do 
      comments_size
    end

    @cached_comments_size = @cached_comments_size.respond_to?(:value) ? @cached_comments_size.value.to_i : @cached_comments_size.to_i
  end

end
