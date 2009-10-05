require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # TBS
    #
    class Attribute < SmellDetector

      def self.contexts      # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class declares any attributes.
      # Remembers any smells found.
      #
      def examine_context(klass)
        klass.attributes.each do |attr|
          found(klass, "declares the attribute #{attr}")
        end
      end
    end
  end
end
