require_relative '../spec_helper'
require_lib 'reek/tree_walker'

RSpec.describe Reek::TreeWalker do
  describe '#initialize' do
    describe 'the structure of the context_tree' do
      let(:walker) do
        code = 'class Car; def drive; end; end'
        described_class.new(syntax_tree(code))
      end
      let(:context_tree) { walker.send :context_tree }

      it 'starts with a root node' do
        expect(context_tree.type).to eq(:root)
        expect(context_tree).to be_a(Reek::Context::RootContext)
      end

      it 'has one child' do
        expect(context_tree.children.size).to eq(1)
      end

      describe 'the root node' do
        let(:module_context) { context_tree.children.first }

        it 'has one module_context' do
          expect(module_context).to be_a(Reek::Context::ModuleContext)
        end

        it 'holds a reference to the parent context' do
          expect(module_context.send(:context)).to eq(context_tree)
        end

        describe 'the module node' do
          let(:method_context) { module_context.children.first }

          it 'has one method_context' do
            expect(method_context).to be_a(Reek::Context::MethodContext)
            expect(module_context.children.size).to eq(1)
          end

          it 'holds a reference to the parent context' do
            expect(method_context.send(:context)).to eq(module_context)
          end
        end
      end
    end
  end

  describe 'statement counting' do
    def tree(code)
      described_class.new(syntax_tree(code)).send(:context_tree)
    end

    def number_of_statements_for(code)
      tree(code).children.first.num_statements
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

  describe '#walk' do
    it 'returns a SmellRepository that contains the reported SmellWarnings' do
      code             = 'def foo; bar.call_me(); bar.call_me(); end'
      tree_walker      = described_class.new syntax_tree(code)
      smell_repository = tree_walker.walk(smell_types: [Reek::Smells::DuplicateMethodCall],
                                          configuration: {})

      smell = smell_repository.send(:detectors).detect do |detector|
        detector.is_a? Reek::Smells::DuplicateMethodCall
      end.send(:smells_found).first

      expect(smell.message).to eq('calls bar.call_me 2 times')
    end
  end
end
