require_relative '../spec_helper'
require_lib 'reek/context_builder'

RSpec.describe Reek::ContextBuilder do
  describe '#context_tree' do
    let(:walker) do
      code = 'class Car; def drive; end; end'
      described_class.new(syntax_tree(code))
    end
    let(:context_tree) { walker.context_tree }
    let(:module_context) { context_tree.children.first }
    let(:method_context) { module_context.children.first }

    it 'starts with a root node' do
      expect(context_tree.type).to eq(:root)
      expect(context_tree).to be_a(Reek::Context::RootContext)
    end

    it 'has one child' do
      expect(context_tree.children.size).to eq(1)
    end

    describe 'the root node' do
      it 'has one module_context' do
        expect(module_context).to be_a(Reek::Context::ModuleContext)
      end

      it 'holds a reference to the parent context' do
        expect(module_context.parent).to eq(context_tree)
      end
    end

    describe 'the module node' do
      it 'has one method_context' do
        expect(method_context).to be_a(Reek::Context::MethodContext)
        expect(module_context.children.size).to eq(1)
      end

      it 'holds a reference to the parent context' do
        expect(method_context.parent).to eq(module_context)
      end
    end
  end

  describe 'statement counting' do
    def tree(code)
      described_class.new(syntax_tree(code)).context_tree
    end

    def number_of_statements_for(code)
      tree(code).children.first.number_of_statements
    end

    it 'counts 1 assignment' do
      code = 'def one() val = 4; end'
      expect(number_of_statements_for(code)).to eq(1)
    end

    it 'counts 3 assignments' do
      code = 'def one() val = 4; val = 4; val = 4; end'
      expect(number_of_statements_for(code)).to eq(3)
    end

    it 'counts 1 attr assignment' do
      code = 'def one() val[0] = 4; end'
      expect(number_of_statements_for(code)).to eq(1)
    end

    it 'counts 1 increment assignment' do
      code = 'def one() val += 4; end'
      expect(number_of_statements_for(code)).to eq(1)
    end

    it 'counts 1 increment attr assignment' do
      code = 'def one() val[0] += 4; end'
      expect(number_of_statements_for(code)).to eq(1)
    end

    it 'counts 1 nested assignment' do
      code = 'def one() val = fred = 4; end'
      expect(number_of_statements_for(code)).to eq(1)
    end

    it 'counts returns' do
      code = 'def one() val = 4; true; end'
      expect(number_of_statements_for(code)).to eq(2)
    end

    it 'counts nil returns' do
      code = 'def one() val = 4; nil; end'
      expect(number_of_statements_for(code)).to eq(2)
    end

    context 'with control statements' do
      it 'counts 3 statements in a conditional expression' do
        code = 'def one() if val == 4; callee(); callee(); callee(); end; end'
        expect(number_of_statements_for(code)).to eq(3)
      end

      it 'counts 3 statements in an else' do
        code = <<-EOS
          def one()
            if val == 4
              callee(); callee(); callee()
            else
              callee(); callee(); callee()
            end
          end
        EOS

        expect(number_of_statements_for(code)).to eq(6)
      end

      it 'does not count constant assignment with or equals' do
        code = 'class Hi; CONST ||= 1; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'does not count multi constant assignment' do
        code = 'class Hi; CONST, OTHER_CONST = 1, 2; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'does not count empty conditional expression' do
        code = 'def one() if val == 4; ; end; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'does not count empty else' do
        code = 'def one() if val == 4; ; else; ; end; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'counts extra statements in an if condition' do
        code = 'def one() if begin val = callee(); val < 4 end; end; end'
        expect(number_of_statements_for(code)).to eq(1)
      end

      it 'counts 3 statements in a while loop' do
        code = 'def one() while val < 4; callee(); callee(); callee(); end; end'
        expect(number_of_statements_for(code)).to eq(3)
      end

      it 'counts extra statements in a while condition' do
        code = 'def one() while begin val = callee(); val < 4 end; end; end'
        expect(number_of_statements_for(code)).to eq(1)
      end

      it 'counts 3 statements in a until loop' do
        code = 'def one() until val < 4; callee(); callee(); callee(); end; end'
        expect(number_of_statements_for(code)).to eq(3)
      end

      it 'counts 3 statements in a for loop' do
        code = 'def one() for i in 0..4; callee(); callee(); callee(); end; end'
        expect(number_of_statements_for(code)).to eq(3)
      end

      it 'counts 3 statements in a rescue' do
        code = <<-EOS
          def one()
            begin
              callee(); callee(); callee()
            rescue
              callee(); callee(); callee()
            end
          end
        EOS
        expect(number_of_statements_for(code)).to eq(6)
      end

      it 'counts 3 statements in a when' do
        code = <<-EOS
          def one()
            case fred
            when "hi" then callee(); callee()
            when "lo" then callee()
            end
          end
        EOS
        expect(number_of_statements_for(code)).to eq(3)
      end

      it 'counts 3 statements in a case else' do
        code = <<-EOS
          def one()
            case fred
            when "hi" then callee(); callee(); callee()
            else           callee(); callee(); callee()
            end
          end
        EOS
        expect(number_of_statements_for(code)).to eq(6)
      end

      it 'does not count empty case' do
        code = 'def one() case fred; when "hi"; ; when "lo"; ; end; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'does not count empty case else' do
        code = 'def one() case fred; when "hi"; ; else; ; end; end'
        expect(number_of_statements_for(code)).to eq(0)
      end

      it 'counts 4 statements in an iterator' do
        code = 'def one() fred.each do; callee(); callee(); callee(); end; end'
        expect(number_of_statements_for(code)).to eq(4)
      end

      it 'counts 1 statement in a singleton method' do
        code = 'def self.foo; callee(); end'
        expect(number_of_statements_for(code)).to eq(1)
      end
    end
  end

  describe 'visibility tracking' do
    def context_tree_for(code)
      described_class.new(syntax_tree(code)).context_tree
    end

    it 'marks instance methods when using a def modifier' do
      code = <<-EOS
        class Foo
          private def bar
          end

          def baz
          end
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      aggregate_failures do
        expect(method_contexts[0].visibility).to eq :private
        expect(method_contexts[1].visibility).to eq :public
      end
    end

    it 'does not mark class methods with instance visibility' do
      code = <<-EOS
        class Foo
          private
          def bar
          end
          def self.baz
          end
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      expect(method_contexts[0].visibility).to eq :private
      expect(method_contexts[1].visibility).to eq :public
    end

    it 'only marks existing instance methods using later instance method modifiers' do
      code = <<-EOS
        class Foo
          def bar
          end

          def baz
          end

          def self.bar
          end

          class << self
            def bar
            end
          end

          private :bar, :baz
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      expect(method_contexts[0].visibility).to eq :private
      expect(method_contexts[1].visibility).to eq :private
      expect(method_contexts[2].visibility).to eq :public
      expect(method_contexts[3].visibility).to eq :public
    end

    it 'only marks existing instance attributes using later instance method modifiers' do
      code = <<-EOS
        class Foo
          attr_writer :bar

          class << self
            attr_writer :bar
          end

          private :bar
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      expect(method_contexts[0].visibility).to eq :private
      expect(method_contexts[1].visibility).to eq :public
    end

    it 'marks class method visibility using private_class_method' do
      code = <<-EOS
        class Foo
          def self.baz
          end

          private_class_method :baz
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      expect(method_contexts[0].visibility).to eq :private
    end

    it 'marks class method visibility using public_class_method' do
      code = <<-EOS
        class Foo
          class << self
            private

            def baz
            end
          end

          public_class_method :baz
        end
      EOS

      root = context_tree_for(code)
      module_context = root.children.first
      method_contexts = module_context.children
      expect(method_contexts[0].visibility).to eq :public
    end

    it 'correctly skips nested modules' do
      code = <<-EOS
        class Foo
          class Bar
            def baz
            end
          end

          def baz
          end

          def self.bar
          end

          private :baz
          private_class_method :bar
        end
      EOS

      root = context_tree_for(code)
      foo_context = root.children.first
      bar_context = foo_context.children.first
      nested_baz_context = bar_context.children.first
      expect(nested_baz_context.visibility).to eq :public
    end
  end

  describe '#context_tree' do
    it 'creates the proper context for all kinds of singleton methods' do
      src = <<-EOS
        class Car
          def self.start; end

          class << self
            def drive; end
          end
        end
      EOS

      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      context_tree = described_class.new(syntax_tree).context_tree

      class_node = context_tree.children.first
      start_method = class_node.children.first
      drive_method = class_node.children.last

      expect(start_method).to be_instance_of Reek::Context::SingletonMethodContext
      expect(drive_method).to be_instance_of Reek::Context::SingletonMethodContext
    end

    it 'returns something sensible for nested metaclasses' do
      src = <<-EOS
        class Foo
          class << self
            class << self
              def bar; end
            end
          end
        end
      EOS

      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      context_tree = described_class.new(syntax_tree).context_tree

      class_context = context_tree.children.first
      method_context = class_context.children.first

      expect(method_context).to be_instance_of Reek::Context::SingletonMethodContext
      expect(method_context.parent).to eq class_context
    end

    it 'returns something sensible for nested method definitions' do
      src = <<-EOS
        class Foo
          def foo
            def bar
            end
          end
        end
      EOS

      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      context_tree = described_class.new(syntax_tree).context_tree

      class_context = context_tree.children.first
      foo_context = class_context.children.first

      bar_context = foo_context.children.first
      expect(bar_context).to be_instance_of Reek::Context::MethodContext
      expect(bar_context.parent).to eq foo_context
    end

    it 'returns something sensible for method definitions nested in singleton methods' do
      src = <<-EOS
        class Foo
          def self.foo
            def bar
            end
          end
        end
      EOS

      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      context_tree = described_class.new(syntax_tree).context_tree

      class_context = context_tree.children.first
      foo_context = class_context.children.first

      bar_context = foo_context.children.first
      expect(bar_context).to be_instance_of Reek::Context::SingletonMethodContext
      expect(bar_context.parent).to eq foo_context
    end
  end
end
