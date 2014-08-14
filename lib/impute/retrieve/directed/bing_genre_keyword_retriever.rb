




module Impute::Retrieve::Directed

  require_relative './directed_retriever.rb'

  class BingGenreKeywordRetriever < Impute::Retrieve::Directed::DirectedRetreiever

    # TODO: handle bing market/languages more betterly
    DEFAULT_LANGUAGE = 'en-GB'

    def initialize(keyword_dir, genre_dim, language_dim)
      @keyword_dir      = keyword_dir
      load_keyword_lists

      @genre_dimname    = genre_dim
      @language_dimname = language_dim
    end

    def properties
       #TODO
      return []
    end

    def retrieve(prototype, number)
      warn "#{self.class} Seeking #{prototype}..."

      # TODO
    end

  private

    def load_keyword_lists
      warn "STUB: load_keyword_lists in ..."
    end

  end
end
