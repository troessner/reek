# frozen_string_literal: true

require 'stringio'

module Reek
  module CLI
    # CLI silencer
    module Silencer
      module_function

      # @quality :reek:TooManyStatements { max_statements: 9 }
      def silently
        old_verbose = $VERBOSE
        old_stderr = $stderr
        old_stdout = $stdout

        $VERBOSE = false
        $stderr = StringIO.new
        $stdout = StringIO.new
        yield
      ensure
        $VERBOSE = old_verbose
        $stderr = old_stderr
        $stdout = old_stdout
      end

      def without_warnings
        old_verbose = $VERBOSE
        $VERBOSE = false
        yield
      ensure
        $VERBOSE = old_verbose
      end
    end
  end
end
