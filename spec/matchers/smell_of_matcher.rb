module SmellOfMatcher
  class SmellOf
    def initialize(klass, *expected_smells)
      @klass = klass
      @expected_smells = expected_smells
      @config = {}
    end

    def failure_message_for_should
      "Expected #{@source.desc} to smell of #{@klass}, but it didn't: #{@reason}"
    end

    def failure_message_for_should_not
      "Expected #{@source.desc} not to smell of #{@klass}, but it did"
    end

    def matches?(src)
      @source = src.to_reek_source

      ctx = MethodContext.new(nil, @source.syntax_tree)
      detector = @klass.new(@source.desc, @klass.default_config.merge(@config))
      detector.examine(ctx)
      actual_smells = detector.smells_found.to_a

      if actual_smells.empty?
        @reason = 'no smells found by detector'
        return false
      end

      actual_smells.each do |smell|
        if smell.smell_class != @klass::SMELL_CLASS ||
          smell.subclass != @klass::SMELL_SUBCLASS
          @reason = "Found #{smell.smell_class}/#{smell.subclass}"
          return false
        end
      end

      expected_number_of_smells = @expected_smells.empty? ? 1 : @expected_smells.length

      if expected_number_of_smells != actual_smells.length
        @reason = "expected #{expected_number_of_smells} smell(s), found #{actual_smells.length}"
        return false
      end

      @expected_smells.zip(actual_smells).each do |expected_smell, actual_smell|
        expected_smell.each do |key, value|
          actual_value = actual_smell.smell[key]
          if actual_value != value
            @reason = "expected #{key} to be #{value}, was #{actual_value}"
            return false
          end
        end
      end

      true
    end

    def with_config(options)
      @config = options
      self
    end
  end

  def smell_of(klass, *smells)
    SmellOf.new(klass, *smells)
  end
end

RSpec.configure do |config|
  config.include(SmellOfMatcher)
end
