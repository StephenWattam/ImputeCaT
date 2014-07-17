


module Impute


  class Corpus

    # Create a new Corpus, from
    # a list of important dimensions of the format:
    #
    #  dimension_name => object.is_a?(Impute::Distribution)
    def initialize(dimensions = {})
      @dimensions = dimensions
      @documents  = []
    end

    def add(document)
      # Merge dimensions into the dimensions vector
      @dimensions.each do |dim, dist|
        # puts "-> #{dim}"

        # Integrate document into marginal distributions for each
        dist.add(document.dimensions[dim])
      end

      # Add document to the list
      @documents << document
    end

    def dimensions
      @dimensions
    end

    def [](dimension)
      @dimensions[dimension]
    end
    alias_method :distribution, :[]

    def to_s
      "#<Corpus:#{@dimensions.size}:#{object_id}>"
    end


    # Compute and return the conditional distribution
    # of all dimensions not mentioned in the list given
    # values in the control_for hash.
    #
    # control_for is:
    #  {:dimension => lambda{|value, document_value| blah return boolean } }
    def conditional_corpus(control_for = {})

      # Construct new distributions for the
      # dimensions in this corpus
      dims = {}
      (dims.keys - control_for.keys).each do |k|
        dims[k] = @dimensions[k].class.new()
      end
      new_corpus = Corpus.new(dims)

      # Add only documents matching the control_for items.
      @documents.each do |doc|
        select = false
        control_for.each do |dim, value_or_lambda|
          # Skip if already selected else select
          select and next
          if value_or_lambda.is_a?(Proc)
            select = (value_or_lambda.call( doc.dimensions[dim] ))
          else
            select = (value_or_lambda == doc.dimensions[dim] )
          end
        end

        new_corpus.add(doc) if select
      end

      return new_corpus
    end

    # Write to an IO handle
    def write(io)
      if io.is_a?(String)
        io = File.open(io, 'w')
        self.write(io)
        io.close
        return
      end

      Marshal.dump(self, io)
    end

    def self.read(io)
      if io.is_a?(String)
        io = File.open(io, 'r')
        corpus = Corpus.read(io)
        io.close
        return corpus
      end
      Marshal.load(io)
    end

  end

end


