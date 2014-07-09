



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
      @bins[value] || 0
    end

  end

  ## A distribution that applies gaussian kernels
  ## to points in order to provide pseudo-continuous
  ## behaviour.
  class SmoothedGaussianDistribution < Distribution

    require 'securerandom'

    # Z score to overestimate min/max
    STDEV_OVERESTIMATE = 3  # 3 is 0.13% beyond bounds.
    TWO_PI             = Math::PI * 2    # It is what it is.

    # Approximate Y maximum by sampling at @bandwidth/10 intervals
    Y_APPROX_RESOLUTION = 10

    # Bandwidth is 1 stdev
    def initialize(bandwidth)
      @points = []
      @n      = 0
      @min    = 0
      @max    = 0

      @bandwidth          = bandwidth
      @overestimate_tails = bandwidth * STDEV_OVERESTIMATE

      @real_y_max = nil
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
      @real_y_max = nil
      @cache      = {}

      @n += 1 
    end

    # Use rejection sampling to find a point under
    # the estimated CDF
    def rand


      # Approximate the y maximum so our rejection sampling
      # isn't horribly inefficient
      approximate_real_y_max unless @real_y_max
    
      puts "x bounds: #{@min}, #{@max}"
      puts "approx max: #{@real_y_max}"

      # At this point the maximum possible value of Y is @n,
      # but that is usually an overestimate.
      rnd        = nil
      threshold  = nil
      iterations = 0
      while(!rnd || rnd > threshold)

        # get a uniform random number within min/max including
        # overestimate for the tails of the smoothing
        xpos = SecureRandom.random_number * ((@max - @min) + 2 * STDEV_OVERESTIMATE) - @min - STDEV_OVERESTIMATE

        # Sample the distribution at that point
        threshold = sample(xpos)

        # Uniform random number up to max of the overall distribution
        rnd = SecureRandom.random_number * @real_y_max
        iterations += 1
      end

      warn "Rejected #{iterations} numbers < #{@n}"
      return rnd
    end

    def sample(x)
      # Loop over points and compute contribution
      # from each.  Stdev is @bandwidth
      y = 0

      return @cache[x] if @cache[x]

      @points.each do |mean|
        y += (1.0 / (@bandwidth * Math.sqrt( TWO_PI ))) * Math.exp( -1 * ((x - mean) ** 2) / (2 * @bandwidth ** 2) )
      end

      # puts "x bounds: #{@min}, #{@max}"
      # puts "Sample at #{x} = #{y}"

      @cache[x] = y
      return y
    end

    private

    # Approximate the y max of the distribution
    # by slicing it into @bandwidth/APPROXIMATION_RESOLUTION
    def approximate_real_y_max
      max = nil

      @points.each do |p|
        puts "#{max} --> #{p}"
        (p - STDEV_OVERESTIMATE .. p + STDEV_OVERESTIMATE).step( @bandwidth / Y_APPROX_RESOLUTION ) do |x|
          y = sample(x)
          max = y if !max || max < y
        end
      end
      # (@min - STDEV_OVERESTIMATE .. @max + STDEV_OVERESTIMATE).step( @bandwidth / Y_APPROX_RESOLUTION ) do |x|
      # end

      @real_y_max = max || 0
    end

  end


end




