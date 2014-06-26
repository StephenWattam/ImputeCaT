


module Impute


  class Document
    
    require 'securerandom'

    attr_reader :dimensions, :id
  
    def initialize(dimensions = {}, id = SecureRandom.uuid)
      @id = id
      @dimensions = dimensions
    end

  end

end


