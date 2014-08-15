

module Impute





  class DocumentStore < Hash

    def make_serialisable!
      self.each do |k, v|
        v.make_serialisable!
      end
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
        corpus = DocumentStore.read(io)
        io.close
        return corpus
      end
      Marshal.load(io)
    end

  end



end
