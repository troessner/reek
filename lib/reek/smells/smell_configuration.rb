module Reek
  module Smells
    #
    # Represents a single set of configuration options for a smell detector
    #
    # @api private
    class SmellConfiguration
      # The name of the config field that specifies whether a smell is
      # enabled. Set to +true+ or +false+.
      ENABLED_KEY = 'enabled'

      # The name of the config field that sets scope-specific overrides
      # for other values in the current smell detector's configuration.
      OVERRIDES_KEY = 'overrides'

      def initialize(hash)
        @options = hash
      end

      def merge!(new_options)
        options.merge!(new_options)
      end

      #
      # Is this smell detector active?
      #--
      #  SMELL: Getter
      def enabled?
        options[ENABLED_KEY]
      end

      def overrides_for(context)
        Overrides.new(options.fetch(OVERRIDES_KEY, {})).for_context(context)
      end

      # Retrieves the value, if any, for the given +key+.
      #
      # Returns +fall_back+ if this config has no value for the key.
      #
      def value(key, context, fall_back)
        overrides_for(context).each { |conf| return conf[key] if conf.key?(key) }
        options.fetch(key, fall_back)
      end

      private

      private_attr_reader :options
    end

    #
    # A set of context-specific overrides for smell detectors.
    #
    # @api private
    class Overrides
      def initialize(hash)
        @hash = hash
      end

      # Find any overrides that match the supplied context
      def for_context(context)
        contexts = hash.keys.select { |ckey| context.matches?([ckey]) }
        contexts.map { |exc| hash[exc] }
      end

      private

      private_attr_reader :hash
    end
  end
end
