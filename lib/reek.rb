#
# Reek's core functionality
#
module Reek
  VERSION = '1.2.8'
end

require File.join(File.dirname(File.expand_path(__FILE__)), 'reek', 'examiner')
require File.join(File.dirname(File.expand_path(__FILE__)), 'reek', 'smell_warning')
