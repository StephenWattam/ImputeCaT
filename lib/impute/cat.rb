



module Impute

  require_relative './document_store.rb'

  class Cat

    attr_accessor :fringe, :sampler, :heuristics, :seed_corpus

    # Used only for a warning.
    MIN_DOC_LENGTH = 100  # bytes.

    def initialize(seed_corpus, sampler, heuristics, strategies, fringe = nil)
      @seed_corpus  = seed_corpus   # The originating corpus description
      @sampler      = sampler       # Way of sampling from the seed corpus
      @heuristics   = heuristics    # The heuristics for scoring/finding docs {dimension => heuristic}
      @search_strategies = strategies # The way to look stuff up

      @fringe       = fringe || DocumentStore.new()
      @prototype    = nil

      @boilerplate_remover = Impute::Process::BoilerplateRemover.new
    end

    def select_prototype
      @prototype = @sampler.get
    end

    def seek_documents
     
      @search_strategies.each do |search_strategy|
        warn "[cat] Using search strategy #{search_strategy}"

        # warn "Seeking '#{metadatum_type}' = '#{metadatum_value}' using heuristic #{heuristic}"

        # Retrieve docs
        search_strategy.retrieve(@prototype, 10) do |doc|
          next unless doc

          # process document (remove boilerplate)
          process_raw_document(doc)

          warn "[cat] Document text length (clean) below #{MIN_DOC_LENGTH}b" if doc.text.to_s.length < MIN_DOC_LENGTH
          
          # impute metadata
          impute_document(doc)

          @fringe[doc.id] = doc
        end
      end

      require 'pry'; pry binding;
    end

    def select_best
      warn "STUB: select_best in Impute::Cat"
    end

  private

    # Remove boilerplate and read easy bits of metadata from the headers
    def process_raw_document(doc)
      @boilerplate_remover.process(doc)
    end

    # Fill in the metadata for a docuiment
    def impute_document(doc)

      # Score the document in all dimensions
      @heuristics.each do |name, heur|
        warn "[cat] Imputing heuristic #{name} on doc #{doc}"
        val = heur.summarise(doc, doc.dimensions[name])
        warn "[cat] heuristic #{name} on doc #{doc} = #{val} for dimension #{name}."
        doc.dimensions[name] = val
      end
    end

  end



end


