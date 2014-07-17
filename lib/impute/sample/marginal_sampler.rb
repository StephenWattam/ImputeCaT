



module Impute::Sample

  require_relative 'sampler.rb'


  class MarginalSampler < Sampler 

    def initialize(corpus)
      @corpus = corpus
    end

    def get
      dims = {}
      @corpus.dimensions.each do |dim, dist|
        dims[dim] = dist.rand
      end

      return Impute::Document.new(dims)
    end

  end



end



