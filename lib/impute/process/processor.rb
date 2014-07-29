


module Impute::Process


  require_relative '../document.rb'

  class Processor


    include Impute

    def process(document = Document.new)
      return document
    end

  end


end
