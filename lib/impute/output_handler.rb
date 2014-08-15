


module Impute


  class OutputHandler

    require_relative './document.rb'

    require 'fileutils'
    require 'csv'
    require 'yaml'

    attr_reader :count

    def initialize(dir)
      @dir = dir
      @count = 0

      FileUtils.mkdir_p(dir) unless File.exist?(dir)
    end

    def write(document, prototype = nil)
      @count += 1
      if prototype
        prototype.make_serialisable!
        document.meta[:prototype] = prototype
      end

      document.make_serialisable!
      filename = File.join(@dir, document.id.to_s)
      warn "[out] Writing doc #{document.id} to #{filename}..."
      File.open(filename, 'w') do |io|
        YAML.dump(document, io)
      end
    end
  end


end
