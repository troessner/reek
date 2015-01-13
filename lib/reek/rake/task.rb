#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'pathname'

module Reek
  #
  # Defines a task library for running reek.
  # (Classes here will be configured via the Rakefile, and therefore will
  # possess a :reek:attribute or two.)
  #
  module Rake
    # A Rake task that runs reek on a set of source files.
    #
    # Example:
    #
    #   require 'reek/rake/task'
    #
    #   Reek::Rake::Task.new do |t|
    #     t.fail_on_error = false
    #   end
    #
    # This will create a task that can be run with:
    #
    #   rake reek
    #
    # Examples:
    #
    #   rake reek                                # checks lib/**/*.rb
    #   rake reek REEK_SRC=just_one_file.rb      # checks a single source file
    #   rake reek REEK_OPTS=-s                   # sorts the report by smell
    #
    class Task < ::Rake::TaskLib
      # Name of reek task.
      # Defaults to :reek.
      attr_accessor :name

      # Array of directories to be added to $LOAD_PATH before running reek.
      # Defaults to ['<the absolute path to reek's lib directory>']
      attr_accessor :libs

      # Glob pattern to match config files.
      # Setting the REEK_CFG environment variable overrides this.
      # Defaults to 'config/**/*.reek'.
      attr_accessor :config_file

      def config_files=(value)
        @config_file = value
      end

      def config_files
        @config_file
      end

      # Glob pattern to match source files.
      # Setting the REEK_SRC environment variable overrides this.
      # Defaults to 'lib/**/*.rb'.
      attr_accessor :source_files

      # String containing commandline options to be passed to Reek.
      # Setting the REEK_OPTS environment variable overrides this value.
      # Defaults to ''.
      attr_accessor :reek_opts

      # Array of commandline options to pass to ruby. Defaults to [].
      attr_accessor :ruby_opts

      # Whether or not to fail Rake when an error occurs (typically when smells are found).
      # Defaults to true.
      attr_accessor :fail_on_error

      # Use verbose output. If this is set to true, the task will print
      # the reek command to stdout. Defaults to false.
      attr_accessor :verbose

      # Defines a new task, using the name +name+.
      def initialize(name = :reek)
        @name = name
        @libs = [File.expand_path(File.dirname(__FILE__) + '/../../../lib')]
        @config_file = nil
        @source_files = nil
        @ruby_opts = []
        @reek_opts = ''
        @fail_on_error = true
        @sort = nil

        yield self if block_given?
        @config_file ||= Pathname.glob('config/**/*.reek').detect(&:file?)
        @source_files ||= 'lib/**/*.rb'
        define
      end

      private

      def define # :nodoc:
        desc 'Check for code smells' unless ::Rake.application.last_comment
        task(name) { run_task }
        self
      end

      def run_task
        return if source_file_list.empty?
        cmd = cmd_words.join(' ')
        puts cmd if @verbose
        raise('Smells found!') if !system(cmd) && fail_on_error
      end

      def self.ruby_exe
        File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
      end

      def cmd_words
        [Task.ruby_exe] +
          ruby_options +
          [%(reek)] +
          [sort_option] +
          config_option +
          source_file_list.map { |fn| %("#{fn}") }
      end

      def config_option
        if config_file
          ['-c', config_file]
        else
          []
        end
      end

      def config_file
        ENV['REEK_CFG'] || @config_file
      end

      def ruby_options
        if bundler?
          %w(-S bundle exec)
        else
          lib_path = @libs.join(File::PATH_SEPARATOR)
          @ruby_opts.clone << "-I\"#{lib_path}\""
        end
      end

      def bundler?
        File.exist?('./Gemfile')
      end

      def sort_option
        ENV['REEK_OPTS'] || @reek_opts
      end

      def source_file_list # :nodoc:
        files = ENV['REEK_SRC'] || @source_files
        return [] unless files
        FileList[files]
      end
    end
  end
end
