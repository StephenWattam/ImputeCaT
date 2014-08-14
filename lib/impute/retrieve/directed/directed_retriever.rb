



module Impute::Retrieve::Directed

  require_relative '../retriever.rb'

  class DirectedRetreiever < Impute::Retrieve::Retriever

    include Impute

    # List the properties of a document that are covered
    def properties
      return []
    end

    def retrieve(prototype, number)
    end

  end


end


