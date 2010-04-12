module SmellOfMatcher
  class SmellOf
    def initialize(klass, *smells)
      @klass = klass
      @smells = smells
      @config = {}
    end

    def failure_message_for_should
      "Expected #{@source.desc} to smell of #{@klass}, but it didn't"
    end

    def failure_message_for_should_not
      "Expected #{@source.desc} not to smell of #{@klass}, but it did"
    end

    def matches?(src)
      @source = src.to_reek_source
      ctx = CodeContext.new(nil, @source.syntax_tree)
      detector = @klass.new(@source.desc, @klass.default_config.merge(@config))
      detector.examine(ctx)
      smells = detector.smells_found.to_a
      if smells.length > 0 && smells[0].smell_class.should == @klass::SMELL_CLASS
        return smells.length == 1 if @smells.empty?
        if @smells.length == smells.length
          @smells.each_with_index do |smell,index|
            return false if smell.any? { |(key,value)| smells[index].smell[key] != value }
          end
        end
      end
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
