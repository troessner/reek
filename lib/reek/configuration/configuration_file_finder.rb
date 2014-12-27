require 'pathname'

module Reek
  module Configuration
    #
    # ConfigurationFileFinder is responsible for finding reeks configuration.
    #
    # There are 3 ways of passing `reek` a configuration file:
    # 1. Using the cli "-c" switch (see "Command line interface" above)
    # 2. Having a file ending with .reek either in your current working directory or in a parent
    #    directory
    # 3. Having a file ending with .reek in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a configuration file is exactly
    # like above.
    module ConfigurationFileFinder
      class << self
        def find(application)
          configuration_by_cli(application) ||
            configuration_in_file_system    ||
            configuration_in_home_directory
        end

        private

        def configuration_by_cli(application)
          return unless application # Return gracefully allowing calls without app context
          config_file_option = application.options.config_file
          return unless config_file_option
          path_name = Pathname.new config_file_option
          raise ArgumentError, "Config file #{path_name} doesn't exist" unless path_name.exist?
          path_name
        end

        def configuration_in_file_system
          detect_or_traverse_up Pathname.pwd
        end

        def configuration_in_home_directory
          detect_configuration_in_directory Pathname.new(Dir.home)
        end

        def detect_or_traverse_up(directory)
          file = detect_configuration_in_directory(directory)
          return file unless file.nil?
          return if directory.root?
          detect_or_traverse_up directory.parent
        end

        def detect_configuration_in_directory(directory)
          Pathname.glob(directory.join('*.reek')).detect(&:file?)
        end
      end
    end
  end
end
