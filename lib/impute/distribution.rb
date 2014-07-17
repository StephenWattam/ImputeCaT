



module Impute


  class Distribution

    def add(value)
    end

    # Return a random item from
    # this distribution
    def rand
      warn "STUB: rand in distribution.rb"
    end

    def sample(value)

    end

    def slice(value = 0)
      warn "STUB: slice in distribution.rb"
      # return uniform random number in sliced range
    end

  end

  class ContinuousDistribution < Distribution
  end



  # Distribution for discrete metadata types
  class DiscreteDistribution < Distribution
    
    require 'securerandom'

    def initialize
      @bins = {}
      @n    = 0
    end

    def add(value)
      value or return;
      @bins[value] ||= 0
      @bins[value] += 1
      @n += 1
    end

    # Use roulette wheel method
    # to get a weighted random
    def rand
      num = SecureRandom.random_number(@n)
      @bins.each do |k, freq|
        num -= freq
        return k if num < 0
      end
    end

    def sample(value)
      (@bins[value] || 0) / @n
    end

  end

  ## A distribution that applies gaussian kernels
  ## to points in order to provide pseudo-continuous
  ## behaviour.
  class SmoothedGaussianDistribution < ContinuousDistribution

    require 'securerandom'

    TWO_PI             = Math::PI * 2    # It is what it is.

    # Bandwidth is 1 stdev
    def initialize(bandwidth)
      @points = []
      @min    = 0
      @max    = 0

      @bandwidth          = bandwidth

      @cache      = {}
    end

    def add(value)
      value or return
      value = value.to_f
      @points << value

      # Update min, max
      @min = [value, @min].min
      @max = [value, @max].max

      # Invalidate any y maximum
      @cache      = {}
    end

    # Sample from the whole sum-of-gaussians PDF
    def rand

      # select which gaussian distribution to sample from at uniform
      point = @points[SecureRandom.random_number(@points.length)]

      # puts "--> #{point}"

      # Select a point on X that is within the distribution.
      # We don't care about Y, it only exists to weight overlapping regions.
      x, _ = gaussian(point, @bandwidth)

      return x
    end

    # Return probability of seeing x.
    def sample(x, skip_cache = false)
      # Loop over points and compute contribution
      # from each.  Stdev is @bandwidth
      y = 0

      return @cache[x] if !skip_cache && @cache[x]

      @points.each do |mean|
        y += (1.0 / (@bandwidth * Math.sqrt( TWO_PI ))) * 
          Math.exp( -1 * ((x - mean) ** 2) / (2 * @bandwidth ** 2) )
      end

      # puts "x bounds: #{@min}, #{@max}"
      # puts "Sample at #{x} = #{y}"

      @cache[x] = y
      return y / @points.length
    end

    private

    # Thanks to http://stackoverflow.com/questions/5825680/code-to-generate-gaussian-normally-distributed-random-numbers-in-ruby
    def gaussian(mean, stddev) 
      theta = 2 * Math::PI * SecureRandom.random_number
      rho = Math.sqrt(-2 * Math.log(1 - SecureRandom.random_number))
      scale = stddev * rho
      x = mean + scale * Math.cos(theta)
      y = mean + scale * Math.sin(theta)
      return x, y
    end

  end



  

end




