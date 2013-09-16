require 'sexp_dresser/source/config_file'
require 'yaml'

module Reek
  module Source

    #
    # A file called <something>.reek containing configuration settings for
    # any or all of the smell detectors.
    #
    class ConfigFile < SexpDresser::Source::ConfigFile

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
        problem("\"#{name}\" is not a code smell") unless klass
        klass
      end

    end
  end
end
