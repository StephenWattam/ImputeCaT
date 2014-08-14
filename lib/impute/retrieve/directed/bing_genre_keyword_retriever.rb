




module Impute::Retrieve::Directed

  require_relative './directed_retriever.rb'

  class BingGenreKeywordRetriever < Impute::Retrieve::Directed::DirectedRetreiever

    require 'csv'

    # TODO: handle bing market/languages more betterly
    DEFAULT_LANGUAGE = 'en-GB'
    BING_MARKETS     = %w{ar-XA bg-BG cs-CZ da-DK de-AT de-CH de-DE el-GR en-AU en-CA en-GB en-ID en-IE en-IN en-MY en-NZ en-PH en-SG en-US en-XA en-ZA es-AR es-CL es-ES es-MX es-US es-XL et-EE fi-FI fr-BE fr-CA fr-CH fr-FR he-IL hr-HR hu-HU it-IT ja-JP ko-KR lt-LT lv-LV nb-NO nl-BE nl-NL pl-PL pt-BR pt-PT ro-RO ru-RU sk-SK sl-SL sv-SE th-TH tr-TR uk-UA zh-CN zh-HK zh-TW}

    def initialize(bing_key, keyword_dir, genre_dim, language_dim, num_keywords = 2)
      @bing_key         = bing_key
      @keyword_dir      = keyword_dir
      load_keyword_lists
      @num_keywords     = num_keywords.to_i

      @genre_dimname    = genre_dim
      @language_dimname = language_dim
    end

    def properties
       #TODO
      return []
    end

    def retrieve(prototype, number)
      warn "#{self.class} Seeking #{number} docs fitting #{prototype}:"
      prototype.describe


      # Step one, get genre and language
      genre    = prototype[@genre_dimname]
      language = prototype[@language_dim]

      # Select keywords
      keywords = sample_keywords(genre, @num_keywords)
      puts "[d-bing] using #{keywords}..."

      # Select a bing market
      bing_market = select_market_from_language(language)
      bing        = Impute::Retrieve::SearchRetriever.new(@bing_key, keywords)

      number.times do 
        yield(bing.retrieve)
      end
    end

  private

    # Get a bing market from the language
    def select_market_from_language(language)
      possibilities = []
      BING_MARKETS.each do |m|
        possibilities << m if m =~ /^#{language}/
      end

      return possibilities.sample || DEFAULT_LANGUAGE
    end

    # Sample a keyword (weighted) from the list for a category 
    # using roulette wheel selection, without replacement
    def sample_keywords(category, n)
      unless @keyword_lists[category]
        warn "Warning: no keyword list for #{category}.  Selecting at random..."
        category = @keyword_lists.keys.sample
      end

      keys    = @keyword_lists[category].keys
      keywords = []

      n.times do
    
        puts "-> #{keywords}"

        counter = rand * @keyword_sums[category].to_f
        puts "-> coubnter: #{counter}"
        keys.each do |kw|
          score = @keyword_lists[category][kw]
          puts "ct: #{counter} -= #{score} (#{kw})"
          counter -= score.to_f
          

          # Skip out at end of counter
          if counter <= 0.0
            puts "Adding #{kw}."
            keywords << kw 
            keys.delete(kw)
            break
          end
        end
      end

      puts  "KEYWORDS: #{keywords}"

      return keywords
    end

    # Load keyword lists from two-column CSV on disk
    def load_keyword_lists

      @keyword_lists = {}
      @keyword_sums  = {} # For roulette-wheel selection

      puts "Loading keyword lists..."
      files = Dir.glob(File.join(@keyword_dir, '*.csv'))
      files.sort!

      files.each_with_index do |fn, i|
        category = File.basename(fn, '.csv')
        print "\r (#{i}/#{files.length}) #{category}..."
        
        keywords = {}
        sum      = 0
        CSV.foreach(fn, headers: true) do |line|
          keywords[line[0]] = line[1].to_f
          sum += line[1].to_f
        end

        @keyword_lists[category] = keywords
        @keyword_sums[category]  = sum
      end

      print "\n"
    end

  end
end





