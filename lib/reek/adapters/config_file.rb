require 'yaml'

module Reek
  class ConfigFile
    @@bad_config_files = []

    def initialize(file_path)
      @file_path = file_path
      @hash = load
    end

    #
    # Configure the given sniffer using the contents of the config file.
    #
    def configure(sniffer)
      @hash.each do |klass_name, config|
        klass = find_class(klass_name)
        sniffer.configure(klass, config) if klass
      end
    end

    def find_class(name)
      begin
        klass = Reek::Smells.const_get(name)
      rescue
        klass = nil
      end
      problem("\"#{name}\" is not a code smell") unless klass
      klass
    end

    def load
      unless @@bad_config_files.include?(@file_path)
        begin
          return YAML.load_file(@file_path) || {}
        rescue Exception => e
          @@bad_config_files << @file_path
          problem(e.to_s)
        end
      end
      return {}
    end

    def problem(reason)
      $stderr.puts "Error: Invalid configuration file \"#{File.basename(@file_path)}\" -- #{reason}"
      # SMELL: Duplication of 'Error:'
    end
  end
end
