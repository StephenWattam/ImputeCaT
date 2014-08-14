





module Impute::Summarise

  require_relative 'heuristic.rb'

  class WordCount < Heuristic

    def initialize()
    end

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
      document.text.to_s.split(/\s+/).length
    end

  end



end



