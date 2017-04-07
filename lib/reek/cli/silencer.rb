# frozen_string_literal: true

require 'stringio'

module Reek
  module CLI
    # CLI silencer
    module Silencer
      module_function

      # :reek:TooManyStatements: { max_statements: 7 }
      def silently
        old_verbose = $VERBOSE
        $VERBOSE = false
        $stderr = StringIO.new
        $stdout = StringIO.new
        yield
      ensure
        $VERBOSE = old_verbose
        $stderr = STDERR
        $stdout = STDOUT
      end
    end
  end
end
