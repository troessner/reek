module Reek
  module CLI
    # CLI silencer
    module Silencer
      def self.silently
        old_verbose, $VERBOSE = $VERBOSE, nil
        yield if block_given?
      ensure
        $VERBOSE = old_verbose
      end
    end
  end
end
