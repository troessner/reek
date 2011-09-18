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
      return false if actual_smells.any? do |expected_smell|
        @reason = "Found #{expected_smell.smell_class}/#{expected_smell.subclass}" &&
        expected_smell.smell_class != @klass::SMELL_CLASS &&
          expected_smell.subclass != @klass::SMELL_SUBCLASS
      end
      return actual_smells.length == 1 if @expected_smells.empty?
      return false unless @expected_smells.length == actual_smells.length
      @expected_smells.each_with_index do |expected_smell,index|
        expected_smell.each do |(key,value)|
          if actual_smells[index].smell[key] != value
            @reason = "#{key} != #{value}"
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

Spec::Runner.configure do |config|
  config.include(SmellOfMatcher)
end
