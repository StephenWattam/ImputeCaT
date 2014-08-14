


module Impute


  class Document
    
    require 'securerandom'

    attr_reader :dimensions, :id
    attr_accessor :meta, :text
  
    def initialize(dimensions = {}, id = SecureRandom.uuid, meta = {})
      @id         = id || SecureRandom.uuid
      @dimensions = dimensions
      @text       = ''
      @meta       = meta
    end

    # Access a dimension by name
    def [](dimname)
      @dimensions[dimname]
    end

    # Display a handy description
    # of the document.
    def to_s
      "#<Document:#{@id}:#{object_id}>"
    end

    # Output a string describing the document
    def describe
      puts "#{@id} (#{object_id})"
      dimensions.each do |dim, value|
        puts "  #{dim}:\t#{value}"
      end
    end

  end

end


