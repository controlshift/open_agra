module Progress
  def goal
    if cached_signatures_size < 500
      (cached_signatures_size + 1).round_to_nearest(100)
    elsif cached_signatures_size < 1000
      (cached_signatures_size + 1).round_to_nearest(200)
    elsif cached_signatures_size < 10000
      (cached_signatures_size + 1).round_to_nearest(1000)
    elsif cached_signatures_size < 50000
      (cached_signatures_size + 1).round_to_nearest(5000)
    elsif cached_signatures_size < 100000
      (cached_signatures_size + 1).round_to_nearest(25000)
    else
      (cached_signatures_size + 1).round_to_nearest(100000)
    end
  end

  def percent_to_goal
    cached_signatures_size * 100 / goal
  end

  def cached_signatures_size
    return @cached_signatures_size if defined?(@cached_signatures_size) # return immediately if we have already calculated this
    @cached_signatures_size = Rails.cache.fetch(signatures_count_key, raw: true) do
      signatures_size
    end
    @cached_signatures_size  = @cached_signatures_size.to_i # we need to do this, because we store as raw in memcached.
  end
end
