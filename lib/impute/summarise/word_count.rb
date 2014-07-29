





module Impute::Summarise

  require_relative 'heuristic.rb'

  class WordCount < Heuristic

    # Retrieve a document from some arbitrary
    # source that conforms to the metadata given
    def retrieve(metadata_value, num_docs = 1)
      # TODO: search using 'totally random' keywords (perhaps from the other dimensions?)
    end

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
      # TODO: strip off tags using nokogiri
      document.text.to_s.split(/\s+/).length
    end

    def to_s
      "<#{@name}:#{self.class}>"
    end

  end



end



