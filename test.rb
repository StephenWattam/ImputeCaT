#!/usr/bin/rbx


puts "ImputeCaT test script."


# Use bundler to import the gems.
require 'rubygems'
require 'bundler/setup' 


require_relative './lib/impute'


FIELDS = {'source'                  => Impute::DiscreteDistribution.new(),
          'source2'                 => Impute::DiscreteDistribution.new(),
          'Informal genre/purpose'  => Impute::DiscreteDistribution.new(),
          'medium'                  => Impute::DiscreteDistribution.new(),
          'computed_words'          => Impute::SmoothedGaussianDistribution.new(10),
}

puts "Creating CSV importer"
importer = Impute::Import::CSVImporter.new( "./test/codes.csv", FIELDS.keys )



puts "Creating a Corpus"
corpus = Impute::Corpus.new(FIELDS)


# --------------------------------
puts "Documents: "
# 100.times do |n|
n = 0
 while( doc = importer.fetch_document() )
  puts "#{n+=1} -> #{doc}"

  corpus.add(doc)
end

# --------------------------------
# puts "Write to disk"
# corpus.write("./test/test.corpus")

# --------------------------------
puts "Some random values:"
100.times do |n|
  corpus.random_document_dist.describe
end
