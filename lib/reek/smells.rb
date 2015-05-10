require 'pathname'

(Pathname.new(__FILE__).dirname + 'smells').children.each do |path|
  next unless path.extname == '.rb'
  require_relative "smells/#{path.basename('.rb')}"
end

module Reek
  #
  # This module contains the various smell detectors.
  #
  module Smells
  end
end
