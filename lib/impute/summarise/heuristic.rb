




module Impute::Summarise


  class Heuristic

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
    end

    # Return 0-1 distance 
    def distance(prototype_value, document_value)
    end

    def to_s
      "<Heuristic:#{self.class}>"
    end

  end



end



