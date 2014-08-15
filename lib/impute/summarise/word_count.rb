





module Impute::Summarise

  require_relative 'heuristic.rb'

  class WordCount < Heuristic

    attr_reader :max_word_distance

    def initialize(max_word_distance)
      @max_word_distance = max_word_distance.to_i
    end

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
      document.text.to_s.split(/\s+/).length
    end

    # Return distance, 0-1
    def distance(prototype_value, document_value)
      word_distance = (prototype_value.to_i - document_value.to_i).abs
      
      if word_distance > @max_word_distance
        warn "[wordct] Max word distance (#{@max_word_distance}) exceeded: #{word_distance}"
        return 1.0
      end

      return (@max_word_distance.to_i - word_distance.to_i).to_f / @max_word_distance.to_f
    end



  end



end



