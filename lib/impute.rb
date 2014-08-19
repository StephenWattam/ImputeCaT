


module Impute

  # Yeah, this is dangerous and insecure.  Ain't a production system though....

  dirs = %w{summarise retrieve retrieve/directed process sample import error}
  dirs << ''

  dirs.each do |d|
    Dir.glob(File.join(File.dirname(__FILE__), './impute/', d, '*.rb')) do |p|
      require_relative p
    end
  end

  VERSION = "0.1.0a"


end
