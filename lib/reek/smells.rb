
#REFACTOR: move smell detector somewhere out dir being globbed and remove requires from smells
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'smell_detector')

Dir.glob(File.join( File.dirname( File.expand_path(__FILE__)), 'smells', '*.rb')).each do|smell|
  require smell.gsub(/\.rb$/, '')
end

module Reek

  #
  # This module contains the various smell detectors.
  #
  module Smells
  end
end
