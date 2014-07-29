



module Impute::Retrieve

  require_relative './retriever.rb'
  require_relative '../document.rb'

  class URLRetriever < Retriever


    require 'open-uri'
    require 'uri'
    require 'nokogiri'

    attr_reader :uri

    def initialize(url)
      @uri = URI.parse(url)
    end

    def retrieve
      response = @uri.open
      charset           = response.charset
      content_type      = response.content_type
      base_uri          = response.base_uri.to_s
      content_encoding  = response.content_encoding.to_s
      last_modified     = response.last_modified.to_s
      body_str          = response.read

      doc = Document.new()
      doc.meta = {charset: charset,
                  content_type: content_type,
                  base_uri: base_uri,
                  content_encoding: content_encoding,
                  last_modified: last_modified,
                  body_str: body_str
      }
      doc.text = body_str

      return doc
    end

  end


end
