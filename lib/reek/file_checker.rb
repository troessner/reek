$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/class_checker'

module Reek

  class FileChecker < Checker

    def initialize(report)
      super(report)
      @description = ''
    end

    def process_class(exp)  # :nodoc:
      Reek::ClassChecker.new(@smells).process(exp)
      s(exp)
    end
  end
end