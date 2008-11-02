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
      return false unless smell.recognise?(exp)
      context.report(smell)
      true
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

    def recognise?(refs)
      @refs = refs
      !refs.self_is_max?
    end

    def detailed_report
      receiver = @refs.max_keys.map {|r| Printer.print(r)}.sort.join(' and ')
      "#{@context} uses #{receiver} more than self"
    end
  end

  class UtilityFunction < Smell
    def recognise?(depends_on_self)
      !depends_on_self
    end

    def detailed_report
      "#{@context} doesn't depend on instance state"
    end
  end

  class LargeClass < Smell
    MAX_ALLOWED = 25

    def self.non_inherited_methods(klass)
      return klass.instance_methods if klass.superclass.nil?
      klass.instance_methods - klass.superclass.instance_methods
    end

    def recognise?(name)
      klass = Object.const_get(name) rescue return
      @num_methods = LargeClass.non_inherited_methods(klass).length
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

    def self.effective_length(name)
      return 500 if name == '*'
      name = name[1..-1] while /^@/ === name
      name.length
    end

    def recognise?(symbol)
      @symbol = symbol.to_s
      UncommunicativeName.effective_length(@symbol) < 2
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

  class ControlCouple < Smell
    def initialize(context, args)
      super
      @args = args
    end

    def recognise?(cond)
      @couple = cond
      cond[0] == :lvar and @args.include?(@couple[1])
    end

    def detailed_report
      "#{@context} is controlled by argument #{Printer.print(@couple)}"
    end
  end
end
