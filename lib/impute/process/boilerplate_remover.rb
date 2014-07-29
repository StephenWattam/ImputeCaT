



module Impute::Process


  class BoilerplateRemover < Processor

    require 'tempfile'

    JUSTEXT_COMMAND = 'python2 /home/wattams/.local/bin/justext'

    def initialize(meta_keys_to_search = ['body_str'], stoplist = 'English')
      @meta_keys_to_search = meta_keys_to_search
      @stoplist = stoplist
    end

    def process(doc = Document.new)
      text = nil

      # Take first match
      @meta_keys_to_search.each do |m|
        break if text = doc.meta[m]
      end
      text = doc.text if text.nil?

      # Write text to a tempfile
      file = Tempfile.new('doc')
      file.write(text.to_s)



      # Strip stuff using justext
      str = `#{JUSTEXT_COMMAND} -s #{@stoplist} '#{file.path}'`
      warn "> Stripped #{text.to_s.length} chars to #{str.to_s.length}"
      doc.text = str
    end
  end



end
