









module Impute::Sample

  require_relative 'sampler.rb'


  class RandomConditionalSampler < Sampler

    require_relative '../distribution.rb'
    require_relative 'marginal_sampler.rb'
    require 'securerandom'

    def initialize(corpus, num_conditions = 1, continuous_sample_width = 0)
      super(corpus)
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
        controlled_values[dim] = @corpus.dimensions[dim].rand
      end

      puts "Conditions: #{controlled_values}"

      # Generate conditional distribution
      conditional_distribution = @corpus.conditional_corpus(controlled_values, @continuous_sample_width)
      sampler = Impute::Sample::MarginalSampler.new(conditional_distribution)

      # Sample from that randomly
      return sampler.get
    end

  end





  class FullConditionalSampler < Sampler


    require_relative '../distribution.rb'
    require_relative 'marginal_sampler.rb'
    require 'securerandom'

    def initialize(corpus, continuous_sample_width, quiet = false)
      super(corpus)
      @continuous_sample_width = continuous_sample_width
      @quiet = quiet
    end

    def get

      conditioned = @corpus
      conditions  = {}

      puts "Selecting random document from #{@corpus}..." unless @quiet
      puts " - dims: #{conditioned.dimensions.length}, docs: #{conditioned.documents.length}"  unless @quiet#// Values: #{conditions}"
      while conditioned.dimensions.length > 1

        # Condition on random variable
        dim_to_condition_on = conditioned.dimensions.keys.sample
        value_to_condition_on = conditioned.dimensions[dim_to_condition_on].rand

        conditioned = conditioned.conditional_corpus( {dim_to_condition_on => value_to_condition_on }, @continuous_sample_width)
        conditions[dim_to_condition_on] = value_to_condition_on


        puts " - dims: #{conditioned.dimensions.length}, docs: #{conditioned.documents.length} (#{dim_to_condition_on} == #{value_to_condition_on})" unless @quiet
      end


      # Here the corpus only has one dimension, so sample from it
      dim, dist = conditioned.dimensions.first
      conditions[dim] = dist.rand

      # require 'pry'; pry binding;
      return Impute::Document.new(conditions)
    end

  end


end




