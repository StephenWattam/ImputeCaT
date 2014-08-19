





module Impute::Retrieve::Directed

  require_relative './directed_retriever.rb'

  class Simulator < Impute::Retrieve::Directed::DirectedRetreiever

    def initialize(document_store)
      @document_store = document_store 
    end

    def retrieve(prototype, number)
      warn "#{self.class} Seeking #{number} docs fitting #{prototype}:"
      prototype.describe

      number.times do 
        id = @document_store.keys.sample
        doc = @document_store[id].dup

        yield(doc)
      end

    end

  end
end





