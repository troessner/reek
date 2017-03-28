# frozen_string_literal: true

module Reek
  #
  # Represents a single set of configuration options for a smell detector
  #
  class SmellConfiguration
    # The name of the config field that specifies whether a smell is
    # enabled. Set to +true+ or +false+.
    ENABLED_KEY = 'enabled'.freeze

    # The name of the config field that sets scope-specific overrides
    # for other values in the current smell detector's configuration.
    OVERRIDES_KEY = 'overrides'.freeze

    def initialize(hash)
      @options = hash
    end

    def merge(new_options)
      options.merge!(new_options)
    end

    def enabled?
      options[ENABLED_KEY]
    end

    def overrides_for(context)
      Overrides.new(options.fetch(OVERRIDES_KEY, {})).for_context(context)
    end

    # Retrieves the value, if any, for the given +key+ in the given +context+.
    #
    # Raises an error if neither the context nor this config have a value for
    # the key.
    #
    def value(key, context)
      overrides_for(context).each { |conf| return conf[key] if conf.key?(key) }
      options.fetch(key)
    end

    private

    attr_reader :options
  end

  #
  # A set of context-specific overrides for smell detectors.
  #
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

    attr_reader :hash
  end
end
