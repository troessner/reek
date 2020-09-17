# frozen_string_literal: true

#
# Reek's core functionality
#
require_relative 'reek/version'
require_relative 'reek/examiner'
require_relative 'reek/report'

module Reek
  DEFAULT_SMELL_CONFIGURATION = File.join(__dir__, '../docs/defaults.reek.yml').freeze
  DEFAULT_CONFIGURATION_FILE_NAME = '.reek.yml'
  DETECTORS_KEY = 'detectors'
  EXCLUDE_PATHS_KEY = 'exclude_paths'
  DIRECTORIES_KEY = 'directories'
end
