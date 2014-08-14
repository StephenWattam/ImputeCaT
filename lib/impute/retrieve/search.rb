

  

module Impute::Retrieve

  require_relative './retriever.rb'
  require_relative './spider.rb'

  class SearchRetriever < Retriever


    require 'base64'
    require 'curb'
    require 'json'

    FAILURE_THRESHOLD = 5
    API_ENDPOINT = 'https://api.datamarket.azure.com/Bing/Search/Web'

    attr_reader :links

    def initialize(key, keywords = [], market = 'en-GB')
      fail "No keywords given" unless keywords.length > 0
      @key = key
      fail "No bing key given" unless @key
      @keywords = keywords.map{|k| k.to_s }

      # FIXME: use the market.
      @market = market

      @links = []
      @failures = 0
    end

    def links_remaining
      @links.length
    end

    def retrieve
      unless @links.empty?
        result = @links.shift
        return parse_result(result)
      end

      raise "Failed to return data from search after #{@failures} retries." if @failures > FAILURE_THRESHOLD

      # Recurse
      @links += search
      @failures += 1 if @links.empty?
      return retrieve
    end

    def search
      authKey = Base64.strict_encode64("#{@key}:#{@key}")
      http = Curl.get(API_ENDPOINT, {:$format => "json", :Query => "'#{@keywords.join(' ')}'"}) do |http|
        http.headers['Authorization'] = "Basic #{authKey}"
        # http.verbose = true
      end

      # Request be made here
      links = []
      begin
        search_data = JSON.parse(http.body_str)

        links += search_data['d']['results']
        puts "[bing] links: #{links.length}"

      rescue JSON::ParserError
        fail "Error parsing result from Bing search.  Perhaps you've exceeded your allowance?"
      end
      @links += links
      return links
    end

  private

    def parse_result(r)
      type        = r['WebResult']
      id          = r['ID']
      title       = r['Title']
      description = r['Description']
      url         = r['Url']
      meta        = {type: type, description: description, title: title}

      retriever = Spider.new([url])
        # URLRetriever.new(url)
      doc = retriever.retrieve  # Oh so Java-y :-(
      return nil unless doc

      # Fill in any missing meta
      doc.meta = doc.meta.merge(meta)

      return doc
    end

  end



  # A spider that starts from a search term
  class SearchSpider < SearchRetriever

    attr_reader :spider

    def initialize(bing_key, keywords)
      super(bing_key, keywords)

      urls = search
      @spider = Spider.new(urls.map{|x| x['Url'] })
    end

    def retrieve
      return @spider.retrieve
    end

  end



end
