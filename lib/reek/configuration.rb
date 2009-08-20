module Reek

  #
  # Represents a single set of configuration options for a smell detector
  #
  class Configuration

    # The name of the config field that specifies whether a smell is
    # enabled. Set to +true+ or +false+.
    ENABLED_KEY = 'enabled'

    # The name of the config field that sets scope-specific overrides
    # for other values in the current smell detector's configuration.
    OVERRIDES_KEY = 'overrides'

    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    # SMELL: Getter
    def enabled?
      @hash[ENABLED_KEY]
    end

    def overrides_for(context)
      overrides = @hash.fetch(OVERRIDES_KEY, {})
      configs = overrides.keys.select {|ckey| context.matches?(ckey)}
      configs.map { |exc| overrides[exc] }
    end

    # Retrieves the value, if any, for the given +key+.
    #
    # Returns +fall_back+ if this config has no value for the key.
    #
    def value(key, context, fall_back)
      overrides_for(context).each { |conf| return conf[key] if conf.has_key?(key) }
      return @hash.fetch(key, fall_back)
    end
  end
end
