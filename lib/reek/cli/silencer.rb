require 'stringio'

module Reek
  module CLI
    # CLI silencer
    module Silencer
      module_function

      def silently(stderr: nil, stdout: nil)
        old_verbose = $VERBOSE
        $VERBOSE = false
        $stderr = StringIO.new if stderr
        $stdout = StringIO.new if stdout
        yield
      ensure
        $VERBOSE = old_verbose
        $stderr = STDERR
        $stdout = STDOUT
      end
    end
  end
end
