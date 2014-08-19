




module Impute::Summarise


  class Heuristic
 
    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
    end

    # Return difference normalised between 0 and 1
    def difference(prototype_value, document_value)
    end

    # Return 0-1 distance 
    def norm_distance(prototype_value, document_value)
    end

    def to_s
      "<Heuristic:#{self.class}>"
    end

  end



end



