




module Impute::Summarise


  class Heuristic

    attr_accessor :name

    def initialize(name = 'Metadata field name')
      @name = name
    end

    # Retrieve a document from some arbitrary
    # source that conforms to the metadata given
    def retrieve(metadata_value, num_docs = 1)
      num_docs.times{ |n| yield(Document.new()) }
    end

    # Summarise a document and return a metadata
    # value
    def summarise(document_contents, existing_metadatum_value = nil)
    end

    def to_s
      "<#{@name}:#{self.class}>"
    end

  end



end



