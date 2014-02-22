require 'yaml'
require 'reek/config_file_exception'

module Reek
  module Source

    #
    # A file called <something>.reek containing configuration settings for
    # any or all of the smell detectors.
    #
    class ConfigFile

      #
      # Load the YAML config file from the supplied +file_path+.
      #
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

      #
      # Find the class with this name if it exsits.
      # If not, report the problem and return +nil+.
      #
      def find_class(name)
        begin
          klass = Reek::Smells.const_get(name)
        rescue
          klass = nil
        end
        report_problem("\"#{name}\" is not a code smell") unless klass
        klass
      end

      #
      # Load the file path with which this was initialized.
      # Empty files are ignored with a warning. All other errors are to be
      # handled farther up the stack.
      #
      def load
        if File.size(@file_path) == 0
          report_problem('Empty file')
          return {}
        end

        begin
          result = YAML.load_file(@file_path) || {}
        rescue => error
          report_error(error.to_s)
        end

        report_error('Not a hash') unless Hash === result

        result
      end

      private

      #
      # Report invalid configuration file to standard
      # Error.
      #
      def report_problem(reason)
        $stderr.puts "Warning: #{message(reason)}"
      end

      #
      # Report invalid configuration file to standard
      # Error.
      #
      def report_error(reason)
        raise ConfigFileException.new message(reason)
      end

      def message(reason)
        "Invalid configuration file \"#{File.basename(@file_path)}\" -- #{reason}"
      end
    end
  end
end
