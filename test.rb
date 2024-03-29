#!/usr/bin/ruby


puts "ImputeCaT test script."


# Use bundler to import the gems.
require 'rubygems'
require 'bundler/setup' 


require_relative './lib/impute'


# TARGET_N = 100

# # Personal corpus data
# FILE   = './test/codes.csv'
# FIELDS = {'source'                  => Impute::DiscreteDistribution.new(),
#           'source2'                 => Impute::DiscreteDistribution.new(),
#           'Informal genre/purpose'  => Impute::DiscreteDistribution.new(),
#           'medium'                  => Impute::DiscreteDistribution.new(),
#           'portion read'                  => Impute::SmoothedGaussianDistribution.new(0.1),
#           'domain'                  => Impute::DiscreteDistribution.new(),
#           'computed_unadjusted_words'          => Impute::SmoothedGaussianDistribution.new(10),
#           'computed_words'          => Impute::SmoothedGaussianDistribution.new(10),
# }


# Lee's BNC index
FILE    = './test/BNC_WORLD_INDEX.csv'
FIELDS = {
          # 'Medium'      => Impute::DiscreteDistribution.new(),
          # 'Domain'      => Impute::DiscreteDistribution.new(),
          'GENRE'         => Impute::DiscreteDistribution.new(),
          'Word Total'    => Impute::SmoothedGaussianDistribution.new(30),
          # 'Author Type' => Impute::DiscreteDistribution.new(),
          'Aud Level'     => Impute::DiscreteDistribution.new(),
          # 'Aud Age'     => Impute::DiscreteDistribution.new(),
          'Language'      => Impute::DiscreteDistribution.new(),
}

puts "Creating CSV importer"
importer = Impute::Import::CSVImporter.new( FILE, FIELDS.keys )



puts "Creating a Corpus"
corpus = Impute::Corpus.new(FIELDS)


# --------------------------------
puts "Loading Documents from CSV..."
# 100.times do |n|
n = 0
 while( doc = importer.fetch_document() )
  # puts "#{n} -> #{doc}"
  # puts "--> #{doc.dimensions.inspect}"

  corpus.add(doc)
  n += 1
end
puts "Loaded #{n} docs."

# --------------------------------
puts "Write to disk"
corpus.write("./test/test.corpus")























# --------------------------------
puts "Some random values:"
puts "computed_words"

# sampler = Impute::Sample::MarginalSampler.new(corpus)
# sampler = Impute::Sample::RandomConditionalSampler.new(corpus, 1, 10)
sampler = Impute::Sample::FullConditionalSampler.new(corpus, 30 * 1.645)


# --------------------------------
#puts "Retrieving #{TARGET_N} docs..."
#TARGET_N.times do |n|
#
 # doc = sampler.get
 # doc.describe
 # puts "-> #{corpus.sample(doc)}"
##
#  # puts "#{doc.dimensions['computed_words']}"
#end




# --------------------------------
# Azure search (bing)
SEARCH_KEY = 'RrPfZ/3LTmimYP4kGtvZHmXV9iNzhf9iZn4A7+Ry9WE'

AUDIENCE_LEVEL_FLEISCH_SCORES = {
  'low' =>  80,
  'med' =>  55,
  'high' => 30
}


# --------------------------------

puts "Loading doc store"
doc_store = nil
doc_store = Impute::DocumentStore.read("./test/fringe") if File.exist?("./test/fringe")
puts "Doc store has #{doc_store.length} documents" if doc_store

OUTPUT_DIR = './test/output'

MAX_WORD_DISTANCE = 1000

# Define heuristics
HEURISTICS = {
  'Word Total' => Impute::Summarise::WordCount.new( MAX_WORD_DISTANCE ),
  'GENRE'      => Impute::Summarise::Genre.new('./resources/list_classifier_dump.dat'),
    #'resources/bnc_genre_frequencies/', './resources/stoplists/English.txt'),
  'Aud Level'   => Impute::Summarise::AudienceLevel.new(AUDIENCE_LEVEL_FLEISCH_SCORES, 'med'),
}

# Define search strategies
SEARCH_STRATEGIES = [
  # STUFF
  Impute::Retrieve::Directed::BingGenreKeywordRetriever.new(SEARCH_KEY, './resources/bnc_genre_keywords/', 'GENRE', 'Language'),
]

puts "Creating output in #{OUTPUT_DIR}..."
output_handler = Impute::OutputHandler.new(OUTPUT_DIR)


puts "Starting cat."
cat = Impute::Cat.new(corpus, sampler, HEURISTICS, SEARCH_STRATEGIES, doc_store, output_handler)



# Select prototype
puts "Selecting prototype..."
cat.select_prototype

puts "Retrieving documents..."
cat.seek_documents(10)


puts "Identifying best document out of #{cat.fringe.length}"
cat.select_best   # outputs a single document

puts "Saving doc store..."
cat.fringe.make_serialisable!
cat.fringe.write("./test/fringe")

require 'pry'; pry binding;


