$:.unshift File.dirname(__FILE__)

require 'reek/class_checker'
require 'reek/report'

module Reek

  def self.analyse(*klasses)
    report = Report.new
    klasses.each do |klass|
      ClassChecker.new(report).check_object(klass)
    end
    report
  end
  
end