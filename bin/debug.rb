require_relative '../lib/reek'

require_relative '../lib/reek/smell_detectors/control_parameter'
require_relative '../lib/reek/examiner'

source = Pathname.new(__dir__).join('../samples/smelly_source/ruby.rb')
puts "=== Source is #{source}"
puts "=== Starting examiner"
examiner = Reek::Examiner.new source, filter_by_smells: ['ControlParameter']
puts "=== Done: Found #{examiner.smells.size} smells"
