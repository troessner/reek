$:.unshift File.dirname(__FILE__)

require 'reek/printer'

module Reek

  class Smell
    def self.convert_camel_case(class_name)
      class_name.gsub(/([a-z])([A-Z])/) { |s| "#{$1} #{$2}"}
    end

    def initialize(context, arg=nil)
      @context = context
    end

    def self.check(exp, context, arg=nil)
      smell = new(context, arg)
      context.report(smell) if smell.recognise?(exp)
    end

    def ==(other)
      self.report == other.report
    end
    
    def name
      self.class.convert_camel_case(self.class.name.split(/::/)[1])
    end

    def report
      "[#{name}] #{detailed_report}"
    end
  end

  class LongParameterList < Smell
    MAX_ALLOWED = 3

    def count_parameters(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[-1] and exp[-1][0] == :block
      result
    end

    def recognise?(args)
      count_parameters(args) > MAX_ALLOWED
    end

    def detailed_report
      "#{@context.to_s} has > #{MAX_ALLOWED} parameters"
    end
  end

  class LongYieldList < LongParameterList
    def recognise?(args)
      Array === args and args.length > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} yields > #{MAX_ALLOWED} parameters"
    end
  end

  class LongMethod < Smell
    MAX_ALLOWED = 5

    def count_statements(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[1] and exp[1][0] == :args
      result
    end

    def recognise?(exp)
      count_statements(exp) > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} has > #{MAX_ALLOWED} statements"
    end
  end

  class LongBlock < Smell
    MAX_ALLOWED = 5

    def count_statements(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[1] and exp[1][0] == :args
      result
    end

    def recognise?(exp)
      count_statements(exp) > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} has a block with > #{MAX_ALLOWED} statements"
    end
  end

  class FeatureEnvy < Smell
    def initialize(context, receiver)
      super
      @receiver = receiver
    end

    def recognise?(calls)
      max = calls.empty? ? 0 : calls.values.max
      return false unless max > calls[:self]
      receivers = calls.keys.select { |key| calls[key] == max }
      @receiver = receivers.map {|r| Printer.print(r)}.sort.join(' or ')
      return true
    end

    def detailed_report
      "#{@context} uses #{@receiver} more than self"
    end
  end

  class UtilityFunction < Smell
    def recognise?(calls)
      calls[:self] == 0
    end

    def detailed_report
      "#{@context} doesn't depend on instance state"
    end
  end

  class LargeClass < Smell
    MAX_ALLOWED = 25

    def recognise?(name)
      kl = Object.const_get(name) rescue return
      num_methods = kl.instance_methods.length - kl.superclass.instance_methods.length
      num_methods > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} has > #{MAX_ALLOWED} methods"
    end
  end

  class UncommunicativeName < Smell
    def initialize(context, symbol_type)
      super
      @symbol_type = symbol_type
    end

    def recognise?(symbol)
      @symbol = symbol.to_s
      return false if @symbol == '*'
      min_len = (/^@/ === @symbol) ? 3 : 2;
      @symbol.length < min_len
    end

    def detailed_report
      "#{@context} uses the #{@symbol_type} name '#{@symbol}'"
    end
  end

  class NestedIterators < Smell
    def recognise?(already_in_iter)
      already_in_iter
    end

    def detailed_report
      "#{@context} has nested iterators"
    end
  end
end
