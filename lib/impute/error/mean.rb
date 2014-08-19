

module Impute::Error


  class Mean

    def initialize
      @errors = {}
      @count = 0
    end

    # Accept a document for output, computing its
    # error
    def accept(prototype, document, heuristics)
    	@count += 1

      # FIXME: use non-normalised diff values
    	heuristics.each do |name, heuristic|
    		@errors[name] ||= 0
    		@errors[name] += heuristic.difference(prototype[name], document[name]).to_f
    	end

      # TODO: indicate whether this error is greater than or less than the current mean
      
    end

    # Print error stats to screen
    def output_error_statistics
      puts "[errh] Error summary for #{@count} documents:"
      @errors.each do |name, err|
      	mean_error = err.to_f / @count.to_f
      	puts "[errh]   - #{name} : #{mean_error}"
      end
    end

  end


end


