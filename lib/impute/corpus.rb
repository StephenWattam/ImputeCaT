


module Impute


  class Corpus

    attr_reader :documents, :dimensions

    # Create a new Corpus, from
    # a list of important dimensions of the format:
    #
    #  dimension_name => object.is_a?(Impute::Distribution)
    def initialize(dimensions = {})
      @dimensions = dimensions
      @documents  = []
    end

    def size
      @documents.length
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

    def compare_to(corpus)
      b = corpus

      fail "Cannot compare corpora with different dimensions" unless self.dimensions.keys.sort == b.dimensions.keys.sort

      logliks = {}
      self.dimensions.each do |dim, dist|
        fail "Cannot compare continuous distributions (#{dim} is continuous)" if dist.is_a?(Impute::ContinuousDistribution)

        sum = 0
        dist.each do |x_i, _|
          o = dist.raw_count(x_i)

          e = dist.n * (b[dim].raw_count(x_i) + o) / (self.size + b.size).to_f
          # puts "=> #{o} / #{e}"

          # compute this iteration's contribution to loglik score
          ll_cont = o > 0 ? o * Math.log( o / e ) : 0
          sum += ll_cont
          # puts "#{o} = #{ll_cont}"
        end

        ll = 2 * sum

        # puts "=> #{dim} = #{ll}"

        logliks[dim] = ll

      end

      return logliks
    end

    def [](dimension)
      @dimensions[dimension]
    end
    alias_method :distribution, :[]

    def to_s
      "#<Corpus:#{@dimensions.size}:#{object_id}>"
    end


    def sample(document, ignore_missing = true)
      p = 1

      @dimensions.each do |dim, dist|
        # puts "# #{p}"
        if document.dimensions[dim] == nil
          p = 0 unless ignore_missing
        else
          # puts "#> #{dim} = #{document.dimensions[dim]} : #{dist.sample(document.dimensions[dim])} ( #{dist} )"
          p *= dist.sample(document.dimensions[dim])
        end
      end

      return p
    end

    # Compute and return the conditional distribution
    # of all dimensions not mentioned in the list given
    # values in the control_for hash.
    #
    # control_for is:
    #  {:dimension => lambda{|value, document_value| blah return boolean } }
    def conditional_corpus(control_for = {}, window = 0)

      # Construct new distributions for the
      # dimensions in this corpus
      dims = {}
      (@dimensions.keys - control_for.keys).each do |k|
        dims[k] = @dimensions[k].dup
      end
      new_corpus = Corpus.new(dims)

      # Epic debug.
      # puts "This corpus has #{@dimensions.length} dimensions and will condition on #{control_for.length} to produce one with #{dims.length}.  They are: \n - #{@dimensions.keys.join("\n - ")}"

      # Add only documents matching the control_for items.
      @documents.each do |doc|
        select = false
        control_for.each do |dim, value|
          # Skip if already selected else select
          select and next
          if @dimensions[dim].is_a?(Impute::ContinuousDistribution)
            dim_value = doc.dimensions[dim].to_f
            # puts "#{value - window} < #{dim_value} < #{value + window}"
            select =  dim_value >= (value - window) && dim_value <= (value + window)
          else
            select = (value == doc.dimensions[dim] )
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


