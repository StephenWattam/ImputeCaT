



module Impute::Import


  require_relative './importer.rb'



  def CSVImporter < Importer
    require 'csv'

    CSV_OPTS = {headers: true}

    def initialize(csv_file, id_field = nil, fields = [])
      @file     = csv_file
      @csv_opts = csv_opts

      fail "Input file does not exist: #{csv_file}" unless File.exist?(csv_file)

      @id_field = id_field
      @fields   = fields

      # Open CSV file
      @csv = CSV.open(@file, "r", CSV_OPTS)
    end



    # Return the number of documents in ths CSV
    def count
      @csv.rewind

      count = 0
      @csv.each{ count += 1 }

      return count
    end

   
    # retrieve a single document's data
    def fetch_document
      # read row
      # align entries
      # return Document.new(...
    end

    # return a list of viable dimnensions
    def list_dimensions
      # Read headers
    end


  end



end


