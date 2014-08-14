









module Impute::Summarise

  require_relative 'heuristic.rb'




  class Genre < Heuristic

    FILE_EXTENSION = '.wrd.fql.csv'

    def initialize(frequency_list_dir, stoplist_file, threshold = 5)
     # Load keyword lists for each category
      keyword_lists = {}
      Dir.glob(File.join(frequency_list_dir, "*#{FILE_EXTENSION}")) do |filename|
        category_name                = File.basename(filename, FILE_EXTENSION)
        keyword_lists[category_name] = filename
      end

      # Load stoplist
      stoplist      = File.read(stoplist_file).lines.map{|x| x.chomp.strip.downcase }

      # Construct a new classifier
      warn "[genre] Constructing classifier..."
      @classifier = ListClassifier.new(keyword_lists, stoplist, threshold)
    end

    # Summarise a document and return a metadata
    # value
    def summarise(document, existing_metadatum_value = nil)
      # Trust existing stuff.
      return existing_metadatum_value if existing_metadatum_value

      # TODO: depending on metadata, simply running the classifier might
      #       not be the best system

      # Classify text
      text = document.text.to_s

      warn "[genre] Classifying #{text.split.length} words..."
      return @classifier.classify(text)
    end

  end






  class ListClassifier

    require 'csv'
    require 'fast-stemmer'

    attr_reader   :stoplist, :lists
    attr_accessor :threshold

    def initialize(keyword_lists = {}, stoplist = [], threshold = 5)
      @threshold  = threshold
      @stoplist   = {}
      stoplist.each { |sw| @stoplist[sw] = true }

      if keyword_lists.is_a?(String)
        load_memdump(keyword_lists)
      else
        load_keyword_lists(keyword_lists)
      end
    end

    # Save the state to a file
    def save(filename)
      hash = { threshold: @threshold,
               lists:     @lists,
               stoplist:  @stoplist
      }

      File.open(filename, 'w') do |io|
        Marshal.dump(hash, io)
      end
    end

    # Return a list of possible categories
    def categories
      @lists.keys
    end

    # Classify a string
    def classify(str)
      # require 'pry'; pry binding;
      str = clean_string(str)

      # build frequency list
      str_freqs = {}
      str.each {|w| str_freqs[w] ||= 0; str_freqs[w] += 1 }
      str_freqs = rank(str_freqs)


      scores = {}
      @lists.each do |category, wordlist|
        scores[category] = score_list(str, str_freqs, wordlist)
      end

      # Find max
      category = scores.sort_by{|c, s| s }
      # category.each do |c, score|
      #   puts " > #{c} \t #{score}"
      # end

      return category.last
    end

    # Opens, reads, parses and classifies file
    def classify_file(filename)
      fail "File does not exist: #{filename}" unless File.exist?(filename)

      # Read string and pass it to classify
      return classify(File.read(filename))
    end

  private

    # Clean a string of punctuation and
    # stem if necessary
    def clean_string(str)
      str   = str.join(' ') if str.is_a?(Array)
      words = str.to_s.split

      words.map! do |word|
        word.downcase!

        # Strip leading/following non-dictionary chars
        word.gsub!(/(^[^\w]+|[^\w]+$)/, '')
        word.gsub!(/'s$/, '')

        # word = word.stem if @stem
        @stoplist[word] ? nil : word
      end

      words.delete(nil)
      words.delete('')

      return words
    end

    # Return a mean significance for all
    # of the items in the list
    def score_list(str, str_freqs, list)

      # Frequencies in order
      freqs       = []
      list_freqs  = []

      str.each do |word|
        if list[word] && list[word] > @threshold # Don't penalise things missing from the lexicon
          freqs << (str_freqs[word] || 0)
          list_freqs << (list[word] || 0)
        end

      end

      return pearson(freqs, list_freqs)
    end

    # Load keyword lists from a type=>filename hash
    def load_keyword_lists(list_hash)
      @lists = {}

      count = 0
      list_hash.each do |category, filename_or_hash|

        cat_list = {}
        print "\r[cls] Loading keyword list #{count+=1} / #{list_hash.length}, #{category}..."

        CSV.foreach(filename_or_hash, headers: true) do |line|

          word = line[0]
          freq = line[1].to_f

          next if @stoplist[word]
          cat_list[word] = freq
        end

        # Compute order from frequency
        cat_list = rank(cat_list)

        @lists[category] = cat_list
      end
      print "\n"
    end

    # Load a Marshalled dump
    def load_memdump(filename)
      hash        = Marshal.load(File.read(filename))
      @lists      = hash[:lists]
      @stoplist   = hash[:stoplist]
      @threshold  = hash[:threshold]
    end

    # Compute PMCC naively
    def pearson(x,y)
      n = [x.length, y.length].min
      return 0 if n == 0

      sumx, sumy, sumxSq, sumySq = 0, 0, 0, 0
      n.times do |i|
        sumx += x[i]
        sumy += y[i]

        sumxSq += x[i]**2
        sumySq += y[i]**2
      end

      pSum = 0
      x.each_with_index{|this_x,i| pSum += this_x * y[i] }

      # Calculate Pearson score
      num = pSum - ( sumx * sumy / n )
      den = ((sumxSq-(sumx**2)/n)*(sumySq-(sumy**2)/n))**0.5
      return 0 if den==0

      r = num/den
      return r
    end

    # Turn a key -> Num hash into a Key=>rank hash
    def rank(hash)
      order = hash.sort_by{|_, v| v}.map{ |k, _| k }.reverse
      order.each_with_index { |k, i| hash[k] = i }
      return hash 
    end

  end



end




