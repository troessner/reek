require 'sexp'
require 'reek/core/method_context'
require 'reek/core/module_context'
require 'reek/core/stop_context'
require 'reek/core/singleton_method_context'

module Reek
  module Core

    #
    # Traverses a Sexp abstract syntax tree and fires events whenever
    # it encounters specific node types.
    #
    # SMELL: This class is responsible for counting statements and for feeding
    # each context to the smell repository.
    class CodeParser
      def initialize(smell_repository, ctx = StopContext.new)
        @smell_repository = smell_repository
        @element = ctx
      end

      def process(exp)
        meth = "process_#{exp[0]}"
        meth = :process_default unless self.respond_to?(meth)
        self.send(meth, exp)
        @element
      end

      def process_default(exp)
        exp.each { |sub| process(sub) if Array === sub }
      end

      def process_module(exp)
        inside_new_context(ModuleContext, exp) do
          process_default(exp)
        end
      end

      alias process_class process_module

      def process_defn(exp)
        inside_new_context(MethodContext, exp) do
          count_statement_list(exp.body)
          process_default(exp)
        end
      end

      def process_defs(exp)
        inside_new_context(SingletonMethodContext, exp) do
          count_statement_list(exp.body)
          process_default(exp)
        end
      end

      def process_args(_) end

      #
      # Recording of calls to methods and self
      #

      def process_call(exp)
        @element.record_call_to(exp)
        process_default(exp)
      end

      alias process_attrasgn process_call
      alias process_op_asgn1 process_call

      def process_ivar(exp)
        @element.record_use_of_self
        process_default(exp)
      end

      alias process_iasgn process_ivar

      def process_self(_)
        @element.record_use_of_self
      end

      alias process_zsuper process_self

      #
      # Statement counting
      #

      def process_iter(exp)
        count_clause(exp[3])
        process_default(exp)
      end

      def process_block(exp)
        count_statement_list(exp[1..-1])
        @element.count_statements(-1)
        process_default(exp)
      end

      def process_if(exp)
        count_clause(exp[2])
        count_clause(exp[3])
        @element.count_statements(-1)
        process_default(exp)
      end

      def process_while(exp)
        count_clause(exp[2])
        @element.count_statements(-1)
        process_default(exp)
      end

      alias process_until process_while

      def process_for(exp)
        count_clause(exp[3])
        @element.count_statements(-1)
        process_default(exp)
      end

      def process_rescue(exp)
        count_clause(exp[1])
        @element.count_statements(-1)
        process_default(exp)
      end

      def process_resbody(exp)
        count_statement_list(exp[2..-1].compact)
        process_default(exp)
      end

      def process_case(exp)
        count_statement_list(exp[2..-1].compact)
        @element.count_statements(-1)
        process_default(exp)
      end

      def process_when(exp)
        count_statement_list(exp[2..-1].compact)
        @element.count_statements(-1)
        process_default(exp)
      end

      private

      def count_clause(sexp)
        @element.count_statements(1) if sexp
      end

      def count_statement_list(statement_list)
        @element.count_statements statement_list.length
      end

      def inside_new_context(klass, exp)
        scope = klass.new(@element, exp)
        push(scope) do
          yield
          check_smells(exp[0])
        end
        scope
      end

      def check_smells(type)
        @smell_repository.examine(@element, type)
      end

      def push(scope)
        orig = @element
        @element = scope
        yield
        @element = orig
      end
    end
  end
end
