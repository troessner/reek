require_relative '../../spec_helper'
require_lib 'reek/context/method_context'
require_lib 'reek/context/module_context'

RSpec.describe Reek::Context::CodeContext do
  context 'name recognition' do
    let(:ctx)       { described_class.new(exp) }
    let(:exp)       { instance_double('Reek::AST::SexpExtensions::ModuleNode') }
    let(:exp_name)  { 'random_name' }
    let(:full_name) { "::::::::::::::::::::#{exp_name}" }

    before do
      allow(exp).to receive(:name).and_return(exp_name)
      allow(exp).to receive(:full_name).and_return(full_name)
    end

    it 'gets its short name from the exp' do
      expect(ctx.name).to eq(exp_name)
    end

    it 'does not match an empty list' do
      expect(ctx.matches?([])).to eq(false)
    end

    it 'does not match when its own short name is not given' do
      expect(ctx.matches?(['banana'])).to eq(false)
    end

    it 'does not let pipe-ended Strings make matching ignore the rest' do
      expect(ctx.matches?(['banana|'])).to eq(false)
    end

    it 'recognises its own short name' do
      expect(ctx.matches?(['banana', exp_name])).to eq(true)
    end

    it 'recognises its short name as a regex' do
      expect(ctx.matches?([/banana/, /#{exp_name}/])).to eq(true)
    end

    it 'does not blow up on []-ended Strings' do
      expect(ctx.matches?(['banana[]', exp_name])).to eq(true)
    end

    context 'when there is an outer' do
      let(:ctx)        { described_class.new(exp) }
      let(:outer_name) { 'another_random sting' }
      let(:outer)      { described_class.new(instance_double('Reek::AST::Node')) }

      before do
        ctx.register_with_parent outer
        allow(outer).to receive(:full_name).at_least(:once).and_return(outer_name)
      end

      it 'creates the correct full name' do
        expect(ctx.full_name).to eq(full_name)
      end

      it 'recognises its own full name' do
        expect(ctx.matches?(['banana', full_name])).to eq(true)
      end

      it 'recognises its full name as a regex' do
        expect(ctx.matches?([/banana/, /#{full_name}/])).to eq(true)
      end
    end
  end

  context 'enumerating syntax elements' do
    context 'in an empty module' do
      let(:ctx) do
        src = 'module Emptiness; end'
        ast = Reek::Source::SourceCode.from(src).syntax_tree
        described_class.new(ast)
      end

      it 'yields no calls' do
        ctx.each_node(:send, []) { |exp| raise "#{exp} yielded by empty module!" }
      end

      it 'yields one module' do
        mods = 0
        ctx.each_node(:module, []) { |_exp| mods += 1 }
        expect(mods).to eq(1)
      end

      it "yields the module's full AST" do
        ctx.each_node(:module, []) do |exp|
          expect(exp).to eq(sexp(:module, sexp(:const, nil, :Emptiness), nil))
        end
      end

      it 'returns an empty array of ifs when no block is passed' do
        expect(ctx.each_node(:if, [])).to be_empty
      end
    end

    context 'with a nested element' do
      let(:ctx) do
        src = "module Loneliness; def calloo; puts('hello') end; end"
        ast = Reek::Source::SourceCode.from(src).syntax_tree
        described_class.new(ast)
      end

      it 'yields no ifs' do
        ctx.each_node(:if, []) { |exp| raise "#{exp} yielded by empty module!" }
      end
      it 'yields one module' do
        expect(ctx.each_node(:module, []).length).to eq(1)
      end

      it "yields the module's full AST" do
        ctx.each_node(:module, []) do |exp|
          expect(exp).to eq sexp(:module,
                                 sexp(:const, nil, :Loneliness),
                                 sexp(:def, :calloo,
                                      sexp(:args),
                                      sexp(:send, nil, :puts, sexp(:str, 'hello'))))
        end
      end

      it 'yields one method' do
        expect(ctx.each_node(:def, []).length).to eq(1)
      end

      it "yields the method's full AST" do
        ctx.each_node(:def, []) { |exp| expect(exp.children.first).to eq(:calloo) }
      end

      it 'ignores the call inside the method if the traversal is pruned' do
        expect(ctx.each_node(:send, [:def])).to be_empty
      end
    end

    it 'finds 3 ifs in a class' do
      src = <<-EOS
        class Scrunch
          def first
            return @field == :sym ? 0 : 3;
          end
          def second
            if @field == :sym
              @other += " quarts"
            end
          end
          def third
            raise 'flu!' unless @field == :sym
          end
        end
      EOS
      ast = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = described_class.new(ast)
      expect(ctx.each_node(:if, []).length).to eq(3)
    end
  end

  describe '#config_for' do
    let(:src) do
      <<-EOS
        # :reek:DuplicateMethodCall: { allow_calls: [ puts ] }')
        def repeated_greeting
          puts 'Hello!'
          puts 'Hello!'
        end
      EOS
    end
    let(:expression) { Reek::Source::SourceCode.from(src).syntax_tree }
    let(:outer) { nil }
    let(:context) { described_class.new(expression) }
    let(:sniffer) { class_double('Reek::SmellDetectors::BaseDetector') }

    before do
      context.register_with_parent(outer)
      allow(sniffer).to receive(:smell_type).and_return('DuplicateMethodCall')
    end

    context 'when there is no outer context' do
      it 'gets its configuration from the expression comments' do
        expect(context.config_for(sniffer)).to eq('allow_calls' => ['puts'])
      end
    end

    context 'when there is an outer context' do
      let(:outer) { described_class.new(instance_double('Reek::AST::Node')) }

      before do
        allow(outer).to receive(:config_for).with(sniffer).and_return(
          'max_calls' => 2)
      end

      it 'merges the outer config with its own configuration' do
        expect(context.config_for(sniffer)).to eq('allow_calls' => ['puts'],
                                                  'max_calls' => 2)
      end
    end
  end

  describe '#register_with_parent' do
    let(:context) { described_class.new(instance_double('Reek::AST::Node')) }
    let(:first_child) { described_class.new(instance_double('Reek::AST::Node')) }
    let(:second_child) { described_class.new(instance_double('Reek::AST::Node')) }

    it "appends the element to the parent context's list of children" do
      first_child.register_with_parent context
      second_child.register_with_parent context

      expect(context.children).to eq [first_child, second_child]
    end
  end

  describe '#each' do
    let(:context) { described_class.new(instance_double('Reek::AST::Node')) }
    let(:first_child) { described_class.new(instance_double('Reek::AST::Node')) }
    let(:second_child) { described_class.new(instance_double('Reek::AST::Node')) }

    it 'yields each child' do
      first_child.register_with_parent context
      second_child.register_with_parent context

      result = []
      context.each do |ctx|
        result << ctx
      end

      expect(result).to eq [context, first_child, second_child]
    end
  end
end
