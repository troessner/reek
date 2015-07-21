require 'pathname'

module Reek
  module Configuration
    class ConfigFileException < StandardError; end
    #
    # ConfigurationFileFinder is responsible for finding reek's configuration.
    #
    # There are 3 ways of passing `reek` a configuration file:
    # 1. Using the cli "-c" switch
    # 2. Having a file ending with .reek either in your current working
    #    directory or in a parent directory
    # 3. Having a file ending with .reek in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    # @api private
    module ConfigurationFileFinder
      module_function

      def find_and_load(params = {})
        load_from_file(find(params))
      end

      # FIXME: switch to kwargs on upgrade to Ruby 2 and drop `params.fetch` calls:
      # def find(options: nil, current: Pathname.pwd, home: Pathname.new(Dir.home))
      def find(params = {})
        options = params.fetch(:options) { nil                    }
        current = params.fetch(:current) { Pathname.pwd           }
        home    = params.fetch(:home)    { Pathname.new(Dir.home) }
        find_by_cli(options) || find_by_dir(current) || find_by_dir(home)
      end

      def find_by_cli(options)
        options && options.config_file
      end

      def find_by_dir(start)
        start.ascend do |dir|
          files = dir.children.select(&:file?).sort
          found = files.find { |file| file.to_s.end_with?('.reek') }
          return found if found
        end
      end

      def load_from_file(path)
        return {} unless path
        begin
          configuration = YAML.load_file(path) || {}
        rescue => error
          raise ConfigFileException, "Invalid configuration file #{path}, error is #{error}"
        end

        unless configuration.is_a? Hash
          raise ConfigFileException, "Invalid configuration file \"#{path}\" -- Not a hash"
        end
        configuration
      end
    end
  end
end
