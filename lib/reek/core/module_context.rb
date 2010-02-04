require File.join( File.dirname( File.expand_path(__FILE__)), 'code_context')
require File.join( File.dirname( File.expand_path(__FILE__)), 'code_parser')
require File.join( File.dirname( File.expand_path(__FILE__)), 'sniffer')

module Reek
  module Core

    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext

      class << self
        def create(outer, exp)
          res = resolve(exp[1], outer)
          new(res[0], res[1], exp)
        end

        def from_s(src)
          source = src.to_reek_source
          sniffer = Sniffer.new(source)
          CodeParser.new(sniffer).do_module_or_class(source.syntax_tree, self)
        end

        def resolve(exp, context)
          unless Array === exp
            return resolve_string(exp.to_s, context)
          end
          name = exp[1]
          case exp[0]
          when :colon2
            return [resolve(name, context)[0], exp[2].to_s]
          when :const
            return [ModuleContext.create(context, exp), name.to_s]
          when :colon3
            return [StopContext.new, name.to_s]
          else
            return [context, name.to_s]
          end
        end

        def resolve_string(str, context)
          return [context, str.to_s] unless str =~ /::/
          resolve(RubyParser.new.parse(str), context)
        end
      end

      def initialize(outer, name, exp)
        super(outer, exp, '::')
        @name = name
        @parsed_methods = []
      end

      def parameterized_methods(min_clump_size)
        @parsed_methods.select {|meth| meth.parameters.length >= min_clump_size }
      end

      def record_method(meth)
        @parsed_methods << meth
      end
    end
  end
end
