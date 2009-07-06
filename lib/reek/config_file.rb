require 'yaml'

module Reek
  class ConfigFile

    def initialize(file_path)
      @file_path = file_path
      @hash = YAML.load_file(@file_path) || {}
      problem('not a Hash') unless Hash === @hash
    end

    #
    # Configure the given sniffer using the contents of the config file.
    #
    def configure(sniffer)
      @hash.each { |klass_name, config|
        sniffer.configure(find_class(klass_name), config)
      }
    end

    def find_class(name)
      klass = Reek::Smells.const_get(name)
      problem("#{name} is not a code smell") unless klass
      klass
    end

    def problem(reason)
      raise "Invalid configuration file \"#{File.basename(@file_path)}\" -- #{reason}"
    end
  end
end
