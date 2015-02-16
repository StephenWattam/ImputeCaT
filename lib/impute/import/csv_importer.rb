



module Impute::Import


  require_relative './importer.rb'
  require_relative '../document.rb'
  require_relative '../summarise/heuristic.rb'

  class CSVImporter < Impute::Import::Importer
    require 'csv'

    DEFAULT_CSV_OPTS = {headers: true}

    def initialize(csv_file, fields = [], id_field = nil, csv_options = DEFAULT_CSV_OPTS)
      @file     = csv_file

      fail "Input file does not exist: #{csv_file}" unless File.exist?(csv_file)

      @id_field = id_field
      @fields   = fields.map { |f| f.is_a?(Impute::Summarise::Heuristic) ? f.name : f.to_s }

      # Open CSV file
      @csv = CSV.open(@file, "r", csv_options)
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
      row = @csv.shift
      return unless row
      doc_data = row.to_hash.select { |k, v| @fields.include?(k) }

      # align entries
      # return Document.new(...
      return Impute::Document.new( doc_data ) unless @id_field
      return Impute::Document.new( doc_data, row.field(@id_field) )
    end

    # return a list of viable dimensions
    def list_dimensions
      # Read headers
    end


  end

end
