


  

module Impute::Retrieve

  require_relative './retriever.rb'
  require_relative './url_retriever.rb'

  class Spider < Retriever

    require 'mechanize'

    def initialize(url = [], cookie_jar = nil)
      @fringe = [url]

      # FIXME: pass in cookie jar.
      @mechanize = Mechanize.new
    end

    # Sort the fringe using a callback
    #
    # sort in descending order of goodness.
    def sort_fringe(sorting_method = ->(a, b){ a <=> b } )
      @fringe.sort! { |a, b| sorting_method.call(a, b) }
    end

    def retrieve
      fail "Fringe is empty." if @fringe.empty?
      
      link = @fringe.shift
      if link.is_a?(Mechanize::Page::Link)
        page = link.click
      else
        page = @mechanize.get(link.to_s)
      end
      @fringe << page.links

      
      # charset           = ?
      content_type      = page.header['content-type']
      base_uri          = page.uri
      # content_encoding  = ?
      last_modified     = page.header['last_modified']
      body_str          = page.body
      title             = page.title

      doc       = Document.new()
      doc.meta  = doc.meta.merge( {title:         title,
                                   content_type:  content_type,
                                   base_uri:      base_uri,
                                   last_modified: last_modified} )
      doc.text  = body_str

      return doc
    end

  end

end
