Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file|
  require_relative File.basename(file, '.rb') unless file == __FILE__
end

module Reek
  #
  # This module contains the various smell detectors.
  #
  module Smells
  end
end
