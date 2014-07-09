


module Impute


  class Document
    
    require 'securerandom'

    attr_reader :dimensions, :id, :text
  
    def initialize(dimensions = {}, id = SecureRandom.uuid)
      @id         = id
      @dimensions = dimensions
      @text       = ''
    end

    # Display a handy description
    # of the document.
    def to_s
      "#<Document:#{@id}:#{object_id}>"
    end

    def describe
      puts "#{@id} (#{object_id})"
      dimensions.each do |dim, value|
        puts "  #{dim}:\t#{value}"
      end
    end

  end

end


