#!/usr/bin/env ruby

# Define a task library for running reek.

require 'rake'
require 'rake/tasklib'

module Reek

  # A Rake task that runs reek on a set of source files.
  #
  # Example:
  #
  #   Reek::RakeTask.new do |t|
  #     t.fail_on_error = false
  #   end
  #
  # This will create a task that can be run with:
  #
  #   rake reek
  #
  # If rake is invoked with a "SPEC=filename" command line option,
  # then the list of spec files will be overridden to include only the
  # filename specified on the command line.  This provides an easy way
  # to run just one spec.
  #
  # If rake is invoked with a "REEK_SORT=order" command line option,
  # then the given sort order will override the value of the +sort+
  # attribute.
  #
  # Examples:
  #
  #   rake reek                                      # run specs normally
  #   rake reek SPEC=just_one_file.rb                # run just one spec file.
  #   rake reek REEK_SORT=smell                      # sort warnings by smell
  #
  class RakeTask < ::Rake::TaskLib

    # Name of reek task. (default is :reek)
    attr_accessor :name

    # Array of directories to be added to $LOAD_PATH before running reek.
    # Defaults to ['<the absolute path to reek's lib directory>']
    attr_accessor :libs

    # Glob pattern to match source files. (default is 'lib/**/*.rb')
    # Setting the REEK_SRC environment variable overrides this.
    attr_accessor :source_files

    # Set the sort order for reported smells (see 'reek --help' for possible values).
    # Setting the REEK_SORT environment variable overrides this.
    attr_accessor :sort

    # Array of commandline options to pass to ruby. Defaults to [].
    attr_accessor :ruby_opts

    # Whether or not to fail Rake when an error occurs (typically when specs fail).
    # Defaults to true.
    attr_accessor :fail_on_error

    # Use verbose output. If this is set to true, the task will print
    # the reek command to stdout. Defaults to false.
    attr_accessor :verbose

    # Defines a new task, using the name +name+.
    def initialize(name = :reek)
      @name = name
      @libs = [File.expand_path(File.dirname(__FILE__) + '/../../../lib')]
      @source_files = nil
      @ruby_opts = []
      @fail_on_error = true
      @sort = nil

      yield self if block_given?
      @source_files ||= 'lib/**/*.rb'
      define
    end

    def define # :nodoc:
      desc "Check for code smells" unless ::Rake.application.last_comment
      task(name) { run_task }
      self
    end
    
    def run_task
      return if source_file_list.empty?
      cmd = cmd_words.join(' ')
      puts cmd if @verbose
      raise("Smells found!") if !system(cmd) and fail_on_error
    end
    
    def self.reek_script
      File.expand_path(File.dirname(__FILE__) + '/../../bin/reek')
    end

    def self.ruby_exe
      File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
    end

    def cmd_words
      [self.class.ruby_exe] +
          ruby_options +
          [ %Q|"#{self.class.reek_script}"| ] +
          [sort_option] +
          source_file_list.collect { |fn| %["#{fn}"] }
    end

    def ruby_options
      lib_path = @libs.join(File::PATH_SEPARATOR)
      @ruby_opts.clone << "-I\"#{lib_path}\""
    end
    
    def sort_option
      env_sort = ENV['REEK_SORT']
      return "--sort #{env_sort}" if env_sort
      return "--sort #{@sort}" if @sort
      ''
    end

    def source_file_list # :nodoc:
      env_src = ENV['REEK_SRC']
      return env_src if env_src
      return FileList[@source_files] if @source_files
      []
    end

  end
end
