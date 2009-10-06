require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A class that publishes a getter or setter for an instance variable
    # invites client classes to become too intimate with its inner workings,
    # and in particular with its representation of state.
    #
    # Currently this detector raises a warning for every +attr+,
    # +attr_reader+, +attr_writer+ and +attr_accessor+ -- including those
    # that are private.
    #
    # TODO:
    # * eliminate private attributes
    # * catch attributes declared "by hand"
    #
    class Attribute < SmellDetector

      def self.contexts      # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class declares any attributes.
      # Remembers any smells found.
      #
      def examine_context(mod)
        # SMELL: Duplication
        # MethodContext, ClassContext and ModuleContext all know which
        # calls constitute attribute declarations. Need a method on
        # ModuleContext: each_public_call.select [names] {...}
        mod.attributes.each do |attr|
          found(mod, "declares the attribute #{attr}")
        end
      end
    end
  end
end
