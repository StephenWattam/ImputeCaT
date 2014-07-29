



module Impute

  require_relative './document_store.rb'

  class Cat

    attr_accessor :fringe, :sampler, :heuristics, :seed_corpus

    def initialize(seed_corpus, sampler, heuristics, fringe = nil)
      @seed_corpus  = seed_corpus   # The originating corpus description
      @sampler      = sampler       # Way of sampling from the seed corpus
      @heuristics   = heuristics    # The heuristics for scoring/finding docs {dimension => heuristic}

      @fringe       = fringe || DocumentStore.new()
      @prototype    = nil
    end

    def select_prototype
      @prototype = @sampler.get
    end

    def seek_documents
      metadatum_type  = @prototype.dimensions.keys.sample
      metadatum_value = @prototype.dimensions[metadatum_type]
      
      heuristic = @heuristics[metadatum_type]
      fail "No heuristic found for property #{metadatum_type}" if heuristic.nil?
      warn "Seeking #{metadatum_type} = #{metadatum_value} using heuristic #{heuristic}"

      # Retrieve docs
      heuristic.retrieve(metadatum_value, 100) do |doc|
        @fringe << doc
      end

      # Impute to ensure fringe is always full
      impute_documents
    end

    def select_best
      warn "STUB: select_best in Impute::Cat"
    end

  private

    def impute_documents

      # Score the document in all dimensions
      @fringe.each do |doc|
        @heuristics.each do |name, heur|
          doc.dimensions[name] = heur.summarise(doc, doc.dimensions[name])
        end
      end
      
    end

  end



end


