





module Impute::Summarise

  require_relative 'heuristic.rb'

  class WordCount < Heuristic

    def initialize(wordlists, fallback_wordlist, bing_key)
      @bing_key = bing_key

      @wordlists        = wordlists
      fail "Wordlists must be given as {'language' => 'filename'} hash." unless @wordlists.is_a?(Hash) && @wordlists.length > 0

      load_wordlists
      
      @default_wordlist = wordlists[fallback_wordlist]
      fail "Fallback wordlist is empty" unless @default_wordlist

      @seed_spiders = []
    end

    # Retrieve a document with the word count given,
    # or as close as possible.
    #
    # Works by searching and spidering out from wordlists.
    #  * Interacts with language when selecting wordlist
    #  * Attempts to interact with domain and genre.
    def retrieve(metadata_value, prototype, num_docs = 1)
      # TODO: search using 'totally random' keywords (perhaps from the other dimensions?)

      # 1. Perform word selection
      get_seeds if @seed_spiders.empty?

      # 2. Pick a random spider and get some URLs from it.
      

    end

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
      # TODO: strip off tags using nokogiri
      document.text.to_s.split(/\s+/).length
    end

    def to_s
      "<#{@name}:#{self.class}>"
    end

  private

    def get_seeds
      # Select word
      word = @default_wordlist.sample


      # Search
      search = Impute::Retrieve::SearchRetriever.new(@bing_key, [word])
      # open URLs in spiders, pop them in @seed_spiders
    end

    def load_wordlists
      @wordlists.each do |language, filename|
        str = File.read(filename).to_s
        lines = str.lines
        lines.delete_if{ |l| l.to_s.chomp.strip.length == 0 }

        @wordlists[language] = lines
      end
    end

  end



end



