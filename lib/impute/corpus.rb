


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

    def to_s
      "#<Corpus:#{@dimensions.size}:#{object_id}>"
    end


    # Compute and return the conditional distribution
    # of all dimensions not mentioned in the list given
    # values in the control_for hash.
    #
    # XXX: May be incredibly slow for large, high-dimensional corpora.
    def conditional_corpus(dim, control_for = {})

      # Construct new distributions for the
      # dimensions in this corpus
      dims = {}
      dims.keys.each do |k|
        dims[k] = @dimensions[k].class.new()
      end
      new_corpus = Corpus.new(dims)

      # Add only documents matching the control_for items.
      @documents.each do |doc|
        select = false
        control_for.each do |dim, value|
          # Skip if already selected else select
          select and next
          select = (doc.dimensions[dim] == value)
        end

        new_corpus.add(doc) if select
      end

      return new_corpus
    end


    # Return the marginal distribution for a given dimension
    def distribution(dim)
      @dimnensions[dim]
    end

    # Return a document randomly
    # sampled from the distribution
    def random_document_dist
      dims = {}
      @dimensions.each do |dim, dist|
        dims[dim] = dist.rand
      end

      return Impute::Document.new(dims)
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


