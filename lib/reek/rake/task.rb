#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'pathname'
require 'English'

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
      # Name of reek task. Defaults to :reek.
      attr_writer :name

      # Path to reek's config file.
      # Setting the REEK_CFG environment variable overrides this.
      attr_writer :config_file

      # Glob pattern to match source files.
      # Setting the REEK_SRC environment variable overrides this.
      # Defaults to 'lib/**/*.rb'.
      attr_writer :source_files

      # String containing commandline options to be passed to Reek.
      # Setting the REEK_OPTS environment variable overrides this value.
      # Defaults to ''.
      attr_writer :reek_opts

      # Whether or not to fail Rake when an error occurs (typically when smells are found).
      # Defaults to true.
      attr_writer :fail_on_error

      # Use verbose output. If this is set to true, the task will print
      # the reek command to stdout. Defaults to false.
      attr_writer :verbose

      def initialize(name = :reek)
        @name          = name
        @reek_opts     = ''
        @fail_on_error = true
        @source_files  = 'lib/**/*.rb'
        @verbose       = false

        yield self if block_given?
        define_task
      end

      private

      def define_task
        desc 'Check for code smells'
        task(@name) { run_task }
      end

      def run_task
        puts "\n\n!!! Running 'reek' rake command: #{command}\n\n" if @verbose
        system(*command)
        abort("\n\n!!! `reek` has found smells - exiting!") if sys_call_failed? && @fail_on_error
      end

      def command
        ['reek', *config_file_as_argument, *reek_opts_as_arguments, *source_files].
          compact.
          reject(&:empty?)
      end

      def source_files
        FileList[ENV['REEK_SRC'] || @source_files]
      end

      def reek_opts
        ENV['REEK_OPTS'] || @reek_opts
      end

      def config_file
        ENV['REEK_CFG'] || @config_file
      end

      def sys_call_failed?
        !$CHILD_STATUS.success?
      end

      def config_file_as_argument
        return [] unless @config_file
        ['-c', @config_file]
      end

      def reek_opts_as_arguments
        reek_opts.split(/\s+/)
      end
    end
  end
end
