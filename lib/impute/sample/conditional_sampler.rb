









module Impute::Sample

  require_relative 'sampler.rb'


  class RandomConditionalSampler < Sampler 

    require_relative '../distribution.rb'
    require_relative 'marginal_sampler.rb'
    require 'securerandom'

    def initialize(corpus, num_conditions = 1, continuous_sample_width = 0)
      @corpus                   = corpus
      @num_conditions           = num_conditions
      @continuous_sample_width  = continuous_sample_width
    end

    def get

      # Select @num_conditions dimensions to condition on
      controlled_dims = @corpus.dimensions.keys
      (@corpus.dimensions.size - @num_conditions).times do |n|
        controlled_dims.delete_at(SecureRandom.random_number(controlled_dims.length))
      end

      # Read distribution objects
      controlled_values = {}
      controlled_dims.each do |dim|
                                   puts "--> '#{dim}"
        controlled_values[dim] = case @corpus.dimensions[dim]
                                 when Impute::ContinuousDistribution
                                   select_random_continuous_value(@corpus.dimensions[dim])
                                 when Impute::DiscreteDistribution
                                   select_random_discrete_value(@corpus.dimensions[dim])
                                 else
                                   nil
                                 end
      end

      puts "Conditions: #{controlled_values}"

      # Generate conditional distribution
      conditional_distribution = @corpus.conditional_corpus(controlled_values)
      sampler = Impute::Sample::MarginalSampler.new(conditional_distribution)

      # Sample from that randomly
      return sampler.get
    end

    private

    def select_random_discrete_value(distribution)
      distribution.rand
    end

    def select_random_continuous_value(distribution)
      ideal_value = distribution.rand
      return lambda { |value| 
        (ideal_value.to_f - value.to_f).abs <= @continuous_sample_width
      }
    end

  end



end




