require_relative '../spec_helper'
require_lib 'reek/tree_walker'
require_lib 'reek/source/source_code'

# Dummy repository to inject into TreeWalker in order to count statements in
# all contexts.
class TestSmellRepository
  attr_accessor :num_statements
  def examine(context)
    self.num_statements = context.num_statements
  end
end

def process_method(source)
  exp = Reek::Source::SourceCode.from(source).syntax_tree
  repository = TestSmellRepository.new
  Reek::TreeWalker.new(repository, exp).walk
  repository
end

def process_singleton_method(source)
  exp = Reek::Source::SourceCode.from(source).syntax_tree
  repository = TestSmellRepository.new
  Reek::TreeWalker.new(repository, exp).walk
  repository
end

RSpec.describe Reek::TreeWalker, 'statement counting' do
  it 'counts 1 assignment' do
    method = process_method('def one() val = 4; end')
    expect(method.num_statements).to eq(1)
  end

  it 'counts 3 assignments' do
    method = process_method('def one() val = 4; val = 4; val = 4; end')
    expect(method.num_statements).to eq(3)
  end

  it 'counts 1 attr assignment' do
    method = process_method('def one() val[0] = 4; end')
    expect(method.num_statements).to eq(1)
  end

  it 'counts 1 increment assignment' do
    method = process_method('def one() val += 4; end')
    expect(method.num_statements).to eq(1)
  end

  it 'counts 1 increment attr assignment' do
    method = process_method('def one() val[0] += 4; end')
    expect(method.num_statements).to eq(1)
  end

  it 'counts 1 nested assignment' do
    method = process_method('def one() val = fred = 4; end')
    expect(method.num_statements).to eq(1)
  end

  it 'counts returns' do
    method = process_method('def one() val = 4; true; end')
    expect(method.num_statements).to eq(2)
  end

  it 'counts nil returns' do
    method = process_method('def one() val = 4; nil; end')
    expect(method.num_statements).to eq(2)
  end

  context 'with control statements' do
    it 'counts 1 statement in a conditional expression' do
      method = process_method('def one() if val == 4; callee(); end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 3 statements in a conditional expression' do
      method = process_method('def one() if val == 4; callee(); callee(); callee(); end; end')
      expect(method.num_statements).to eq(3)
    end

    it 'counts 1 statements in an else' do
      method = process_method('def one() if val == 4; callee(); else; callee(); end; end')
      expect(method.num_statements).to eq(2)
    end

    it 'counts 3 statements in an else' do
      method = process_method('
        def one()
          if val == 4
            callee(); callee(); callee()
          else
            callee(); callee(); callee()
          end
        end
                              ')
      expect(method.num_statements).to eq(6)
    end

    it 'does not count constant assignment with or equals' do
      source = 'class Hi; CONST ||= 1; end'
      klass = process_method(source)
      expect(klass.num_statements).to eq(0)
    end

    it 'does not count multi constant assignment' do
      source = 'class Hi; CONST, OTHER_CONST = 1, 2; end'
      klass = process_method(source)
      expect(klass.num_statements).to eq(0)
    end

    it 'does not count empty conditional expression' do
      method = process_method('def one() if val == 4; ; end; end')
      expect(method.num_statements).to eq(0)
    end

    it 'does not count empty else' do
      method = process_method('def one() if val == 4; ; else; ; end; end')
      expect(method.num_statements).to eq(0)
    end

    it 'counts extra statements in an if condition' do
      method = process_method('def one() if begin val = callee(); val < 4 end; end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 1 statement in a while loop' do
      method = process_method('def one() while val < 4; callee(); end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 3 statements in a while loop' do
      source = 'def one() while val < 4; callee(); callee(); callee(); end; end'
      expect(process_method(source).num_statements).to eq(3)
    end

    it 'counts extra statements in a while condition' do
      method = process_method('def one() while begin val = callee(); val < 4 end; end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 1 statement in a until loop' do
      method = process_method('def one() until val < 4; callee(); end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 3 statements in a until loop' do
      source = 'def one() until val < 4; callee(); callee(); callee(); end; end'
      expect(process_method(source).num_statements).to eq(3)
    end

    it 'counts 1 statement in a for loop' do
      method = process_method('def one() for i in 0..4; callee(); end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 3 statements in a for loop' do
      source = 'def one() for i in 0..4; callee(); callee(); callee(); end; end'
      expect(process_method(source).num_statements).to eq(3)
    end

    it 'counts 1 statement in a rescue' do
      method = process_method('def one() begin; callee(); rescue; callee(); end; end')
      expect(method.num_statements).to eq(2)
    end

    it 'counts 3 statements in a rescue' do
      method = process_method('
        def one()
          begin
            callee(); callee(); callee()
          rescue
            callee(); callee(); callee()
          end
        end
                              ')
      expect(method.num_statements).to eq(6)
    end

    it 'counts 1 statement in a when' do
      method = process_method('def one() case fred; when "hi"; callee(); end; end')
      expect(method.num_statements).to eq(1)
    end

    it 'counts 3 statements in a when' do
      method = process_method('
        def one()
          case fred
          when "hi" then callee(); callee()
          when "lo" then callee()
          end
        end
                              ')
      expect(method.num_statements).to eq(3)
    end

    it 'counts 1 statement in a case else' do
      source = 'def one() case fred; when "hi"; callee(); else; callee(); end; end'
      expect(process_method(source).num_statements).to eq(2)
    end

    it 'counts 3 statements in a case else' do
      method = process_method('
        def one()
          case fred
          when "hi" then callee(); callee(); callee()
          else           callee(); callee(); callee()
          end
        end
                              ')
      expect(method.num_statements).to eq(6)
    end

    it 'does not count empty case' do
      method = process_method('def one() case fred; when "hi"; ; when "lo"; ; end; end')
      expect(method.num_statements).to eq(0)
    end

    it 'does not count empty case else' do
      method = process_method('def one() case fred; when "hi"; ; else; ; end; end')
      expect(method.num_statements).to eq(0)
    end

    it 'counts 2 statement in an iterator' do
      method = process_method('def one() fred.each do; callee(); end; end')
      expect(method.num_statements).to eq(2)
    end

    it 'counts 4 statements in an iterator' do
      source = 'def one() fred.each do; callee(); callee(); callee(); end; end'
      expect(process_method(source).num_statements).to eq(4)
    end

    it 'counts 1 statement in a singleton method' do
      method = process_singleton_method('def self.foo; callee(); end')
      expect(method.num_statements).to eq(1)
    end
  end
end
