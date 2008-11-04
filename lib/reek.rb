$:.unshift File.dirname(__FILE__)

require 'reek/file_checker'
require 'reek/report'

module Reek # :doc:

  #
  # Analyse the given source, looking for code smells.
  # The source can be a filename or a String containing Ruby code.
  # Returns a +Report+ listing the smells found.
  #
  def self.analyse(src)  # :doc:
    report = Report.new
    source = Reek.get_source(src)
    FileChecker.new(report).check_source(source)
    report
  end

private

  def self.get_source(src)
    File.exists?(src) ? IO.readlines(src).join : src
  end
end
