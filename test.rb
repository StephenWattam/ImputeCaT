#!/usr/bin/rbx


puts "ImputeCaT test script."


# Use bundler to import the gems.
require 'rubygems'
require 'bundler/setup' 


require_relative './lib/impute'


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
          'Medium'      => Impute::DiscreteDistribution.new(),
          'Domain'      => Impute::DiscreteDistribution.new(),
          'GENRE'       => Impute::DiscreteDistribution.new(),
          'Word Total'  => Impute::SmoothedGaussianDistribution.new(30),
          'Author Type' => Impute::DiscreteDistribution.new(),
          'Aud Level'   => Impute::DiscreteDistribution.new(),
          'Aud Age'     => Impute::DiscreteDistribution.new(),
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

  # puts "-> #{doc.dimensions['computed_words']}"

  corpus.add(doc)
  n += 1
end
puts "Loaded #{n} docs."

# --------------------------------
# puts "Write to disk"
# corpus.write("./test/test.corpus")

# --------------------------------
puts "Some random values:"
puts "computed_words"

sampler = Impute::Sample::MarginalSampler.new(corpus)
# sampler = Impute::Sample::RandomConditionalSampler.new(corpus, 1, 10)

100.times do |n|

  doc = sampler.get
  doc.describe

  # puts "#{doc.dimensions['computed_words']}"
end


