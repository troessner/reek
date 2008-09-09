$:.unshift File.dirname(__FILE__)

require 'reek/class_checker'
require 'reek/report'

module Reek # :doc:

    #
    # Analyse the given instances of class Class, looking for code smells.
    # Returns a +Report+ listing the smells found.
    #
    def self.analyse(*klasses)  # :doc:
      report = Report.new
      klasses.each do |klass|
        ClassChecker.new(report).check_object(klass)
      end
      report
    end    
end