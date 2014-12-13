module SmellOfMatcher
  class SmellOf
    def initialize(klass, *expected_smells)
      @klass = klass
      @expected_smells = expected_smells
      @config = {}
    end

    def failure_message
      "Expected #{@source.desc} to smell of #{@klass}, but it didn't: #{@reason}"
    end

    def failure_message_when_negated
      "Expected #{@source.desc} not to smell of #{@klass}, but it did"
    end

    def matches?(src)
      @source = src.to_reek_source

      detect_smells

      return false if no_smells_found?
      return false if wrong_number_of_smells_found?
      return false if wrong_smell_details_found?

      true
    end

    def with_config(options)
      @config = options
      self
    end

    private

    def detect_smells
      tree = @source.syntax_tree
      ctx = case tree.type
            when :def, :defs
              MethodContext.new(nil, tree)
            when :module, :class
              ModuleContext.new(nil, tree)
            else
              CodeContext.new(nil, tree)
            end
      detector = @klass.new(@source.desc, @klass.default_config.merge(@config))
      detector.examine(ctx)
      @actual_smells = detector.smells_found.to_a
    end

    def no_smells_found?
      return false if @actual_smells.any?
      @reason = 'no smells found by detector'
      true
    end

    def wrong_number_of_smells_found?
      return false if @expected_smells.empty?
      return false if expected_number_of_smells == actual_number_of_smells

      @reason = "expected #{expected_number_of_smells} smell(s), " \
                "found #{actual_number_of_smells}"
      true
    end

    def expected_number_of_smells
      @expected_number_of_smells ||= @expected_smells.length
    end

    def actual_number_of_smells
      @actual_number_of_smells ||= @actual_smells.length
    end

    def wrong_smell_details_found?
      @expected_smells.zip(@actual_smells).each do |expected_smell, actual_smell|
        expected_smell.each do |key, value|
          actual_value = actual_smell.parameters[key]
          next if actual_value == value

          @reason = "expected #{key} to be #{value}, was #{actual_value}"
          return true
        end
      end
      false
    end
  end

  def smell_of(klass, *smells)
    SmellOf.new(klass, *smells)
  end
end

RSpec.configure do |config|
  config.include(SmellOfMatcher)
end
