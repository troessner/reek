$:.unshift File.dirname(__FILE__)

require 'reek/printer'
require 'reek/options'

module Reek

  class Smell
    include Comparable
  
    def self.convert_camel_case(class_name)
      class_name.gsub(/([a-z])([A-Z])/) { |s| "#{$1} #{$2}"}
    end

    def initialize(context, arg=nil)
      @context = context
    end

    def self.check(exp, context, arg=nil)
      smell = new(context, arg)
      if smell.recognise?(exp)
        context.report(smell)
        true
      else
        false
      end
    end
    
    def recognise?(stuff)
      @context != nil
    end

    def hash  # :nodoc:
      report.hash
    end

    def <=>(other)  # :nodoc:
      Options[:sort_order].compare(self, other)
    end

    alias eql? <=>
    
    def name
      self.class.convert_camel_case(self.class.name.split(/::/)[1])
    end

    def report
      "[#{name}] #{detailed_report}"
    end

    alias inspect report

    def to_s
      report
    end
  end

  class LongParameterList < Smell
    MAX_ALLOWED = 3

    def self.count_parameters(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[-1] and exp[-1][0] == :block
      result
    end

    def recognise?(args)
      @num_params = LongParameterList.count_parameters(args)
      @num_params > MAX_ALLOWED
    end

    def detailed_report
      "#{@context.to_s} has #{@num_params} parameters"
    end
  end

  class LongYieldList < LongParameterList
    def recognise?(args)
      @num_params = args.length
      Array === args and @num_params > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} yields #{@num_params} parameters"
    end
  end

  class LongMethod < Smell
    MAX_ALLOWED = 5

    def recognise?(num_stmts)
      @num_stmts = num_stmts
      num_stmts > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} has approx #{@num_stmts} statements"
    end
  end

  class FeatureEnvy < Smell
    
    # TODO
    # Should be moved to Hash; but Hash has 58 methods, and there's currently
    # no way to turn off that report; which would therefore make the tests fail
    def self.max_keys(calls)
      max = calls.values.max or return [:self]
      calls.keys.select { |key| calls[key] == max }
    end

    def initialize(context, *receivers)
      super(context)
      @receivers = receivers
    end

    def recognise?(calls)
      @receivers = FeatureEnvy.max_keys(calls)
      return !(@receivers.include?(:self))
    end

    def detailed_report
      receiver = @receivers.map {|r| Printer.print(r)}.sort.join(' and ')
      "#{@context} uses #{receiver} more than self"
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
      klass = Object.const_get(name) rescue return
      @num_methods = klass.instance_methods.length - klass.superclass.instance_methods.length
      @num_methods > MAX_ALLOWED
    end

    def detailed_report
      "#{@context} has #{@num_methods} methods"
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
