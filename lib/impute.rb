


module Impute


  require_relative './impute/import/importer.rb'
  require_relative './impute/import/csv_importer.rb'

  require_relative './impute/cat'
  require_relative './impute/document_store'
  require_relative './impute/corpus'
  require_relative './impute/distribution'

  require_relative './impute/sample/sampler.rb'
  require_relative './impute/sample/marginal_sampler.rb'
  require_relative './impute/sample/conditional_sampler.rb'

  require_relative './impute/summarise/heuristic.rb'
  require_relative './impute/summarise/word_count.rb'

  Dir.glob(File.join(File.dirname(__FILE__), './impute/retrieve/*.rb')) do |p|
    require_relative p
  end
  
  Dir.glob(File.join(File.dirname(__FILE__), './impute/retrieve/directed/*.rb')) do |p|
    require_relative p
  end

  
  Dir.glob(File.join(File.dirname(__FILE__), './impute/process/*.rb')) do |p|
    require_relative p
  end


  VERSION = "0.1.0a"


end
