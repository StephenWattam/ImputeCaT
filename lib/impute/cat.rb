



module Impute

  require_relative './document_store.rb'

  class Cat

    attr_accessor :fringe, :sampler, :heuristics, :seed_corpus
    attr_reader   :prototype

    require 'matrix'

    # Used only for a warning.
    MIN_DOC_LENGTH = 100  # bytes.

    def initialize(seed_corpus, sampler, heuristics, strategies, fringe, output_handler, error_measure)
      @seed_corpus  = seed_corpus      # The originating corpus description
      @sampler      = sampler          # Way of sampling from the seed corpus
      @heuristics   = heuristics       # The heuristics for scoring/finding docs {dimension => heuristic}
      @search_strategies = strategies  # The way to look stuff up
      @output_handler = output_handler # What to do with selected documents
      @error_measure  = error_measure  # How to measure error

      @fringe       = fringe || DocumentStore.new()
      @prototype    = nil

      @boilerplate_remover = Impute::Process::BoilerplateRemover.new
    end

    def select_prototype
      @prototype = @sampler.get
    end

    def seek_documents(n)

      @search_strategies.each do |search_strategy|
        warn "[cat] Using search strategy #{search_strategy}"

        # warn "Seeking '#{metadatum_type}' = '#{metadatum_value}' using heuristic #{heuristic}"

        # Retrieve docs
        search_strategy.retrieve(@prototype, n) do |doc|
          next unless doc

          # process document (remove boilerplate)
          process_raw_document(doc)

          warn "[cat] Document text length (clean) below #{MIN_DOC_LENGTH}b" if doc.text.to_s.length < MIN_DOC_LENGTH

          # impute metadata
          impute_document(doc)

          @fringe[doc.id] = doc
        end
      end

      # require 'pry'; pry binding;
    end

    # Select the best of the fringe
    def select_best
      return nil if @fringe.length == 0

      # This is done by computing normalised scores for each dimension, then
      # finding out the smallest distance from the prototype

      distances = {}

      @fringe.each do |id, doc|

        # Create a list for each doc
        list = []

        # For each heuristic, add to the list
        @heuristics.each do |key, heuristic|
          score = heuristic.norm_distance(@prototype[key], doc[key]).to_f
          # puts "-> #{id}[#{key}] = #{score}"
          list << score
        end

        # Create a vector from the list, and return its magnitude
        # to normalise
        v = Vector.[](*list)

        distances[id] = v.magnitude
      end


      id, distance = distances.sort_by{|id, dist| dist}.first
      w_id, w_distance = distances.sort_by{|id, dist| dist}.last
      warn "[cat] Selecting document #{id} with distance #{distance} to prototype (worst is #{id} with #{w_distance})."

      # Read doc, remove from fringe, add to output handler
      doc = @fringe[id]
      @fringe.delete(id)

      # TODO: compute MSE and store in the cat for retrieval
      @error_measure.accept(prototype, doc, @heuristics)
      # mse[dimension] = non-normalised-diff(prototype[dimension], doc[dimension])
      @error_measure.output_error_statistics

      # Write out and return
      @output_handler.write(doc)
      return doc
    end

  private

    # Score all documents in the fringe against the prototype,
    # in one dimension only
    # returning raw distances and normalised distances on the scale 0-1
    def score_documents(prototype, key, heuristic)
      doc_scores_by_id = {}

      # Score documents according to the heuristics
      @fringe.each do |id, doc|
        dist = heuristic.distance(prototype[key], doc[key]).to_f
        doc_scores_by_id[id] = dist
      end

      # Unarrayise the maxmin counters
      max_dist = max_dist.shift.to_f
      min_dist = min_dist.shift.to_f
      range = max_dist - min_dist

      # Normalise
      doc_scores_by_id.each do |id, score|
        norm_scores[id] = (score - min_dist) / range
      end

      return norm_scores, doc_scores_by_id
    end

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


