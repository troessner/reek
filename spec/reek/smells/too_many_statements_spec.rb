require 'spec_helper'
require 'reek/smells/too_many_statements'
require 'reek/core/code_parser'
require 'reek/core/sniffer'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

def process_method(src)
  source = src.to_reek_source
  sniffer = Core::Sniffer.new(source)
  Core::CodeParser.new(sniffer).process_defn(source.syntax_tree)
end

def process_singleton_method(src)
  source = src.to_reek_source
  sniffer = Core::Sniffer.new(source)
  Core::CodeParser.new(sniffer).process_defs(source.syntax_tree)
end

describe TooManyStatements do
  it 'should not report short methods' do
    src = 'def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end'
    src.should_not smell_of(TooManyStatements)
  end

  it 'should report long methods' do
    src = 'def long() alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end'
    src.should reek_only_of(:TooManyStatements, /6 statements/)
  end

  it 'should not report initialize' do
    src = 'def initialize(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end'
    src.should_not smell_of(TooManyStatements)
  end

  it 'should only report a long method once' do
    src = <<EOS
def standard_entries(rbconfig)
  @abc = rbconfig
  rubypath = File.join(@abc['bindir'], @abcf['ruby_install_name'] + cff['EXEEXT'])
  major = yyy['MAJOR'].to_i
  minor = zzz['MINOR'].to_i
  teeny = ccc['TEENY'].to_i
  version = ""
  if c['rubylibdir']
    @libruby         = "/lib/ruby"
    @librubyver      = "/lib/ruby/"
    @librubyverarch  = "/lib/ruby/"
    @siteruby        = "lib/ruby/version/site_ruby"
    @siterubyver     = siteruby
    @siterubyverarch = "$siterubyver/['arch']}"
  end
end
EOS
    src.should reek_only_of(:TooManyStatements)
  end

  it 'should report long inner block' do
    src = <<EOS
def long()
  f(3)
  self.each do |xyzero|
    xyzero = 1
    xyzero = 2
    xyzero = 3
    xyzero = 4
    xyzero = 5
    xyzero = 6
  end
end
EOS
    src.should reek_only_of(:TooManyStatements)
  end
end

describe TooManyStatements do
  it 'counts 1 assignment' do
    method = process_method('def one() val = 4; end')
    method.num_statements.should == 1
  end

  it 'counts 3 assignments' do
    method = process_method('def one() val = 4; val = 4; val = 4; end')
    method.num_statements.should == 3
  end

  it 'counts 1 attr assignment' do
    method = process_method('def one() val[0] = 4; end')
    method.num_statements.should == 1
  end

  it 'counts 1 increment assignment' do
    method = process_method('def one() val += 4; end')
    method.num_statements.should == 1
  end

  it 'counts 1 increment attr assignment' do
    method = process_method('def one() val[0] += 4; end')
    method.num_statements.should == 1
  end

  it 'counts 1 nested assignment' do
    method = process_method('def one() val = fred = 4; end')
    method.num_statements.should == 1
  end

  it 'counts returns' do
    method = process_method('def one() val = 4; true; end')
    method.num_statements.should == 2
  end
end

describe TooManyStatements, 'does not count control statements' do
  it 'counts 1 statement in a conditional expression' do
    method = process_method('def one() if val == 4; callee(); end; end')
    method.num_statements.should == 1
  end

  it 'counts 3 statements in a conditional expression' do
    method = process_method('def one() if val == 4; callee(); callee(); callee(); end; end')
    method.num_statements.should == 3
  end

  it 'does not count empty conditional expression' do
    method = process_method('def one() if val == 4; ; end; end')
    method.num_statements.should == 0
  end

  it 'counts 1 statement in a while loop' do
    method = process_method('def one() while val < 4; callee(); end; end')
    method.num_statements.should == 1
  end

  it 'counts 3 statements in a while loop' do
    method = process_method('def one() while val < 4; callee(); callee(); callee(); end; end')
    method.num_statements.should == 3
  end

  it 'counts 1 statement in a until loop' do
    method = process_method('def one() until val < 4; callee(); end; end')
    method.num_statements.should == 1
  end

  it 'counts 3 statements in a until loop' do
    method = process_method('def one() until val < 4; callee(); callee(); callee(); end; end')
    method.num_statements.should == 3
  end

  it 'counts 1 statement in a for loop' do
    method = process_method('def one() for i in 0..4; callee(); end; end')
    method.num_statements.should == 1
  end

  it 'counts 3 statements in a for loop' do
    method = process_method('def one() for i in 0..4; callee(); callee(); callee(); end; end')
    method.num_statements.should == 3
  end

  it 'counts 1 statement in a rescue' do
    method = process_method('def one() begin; callee(); rescue; callee(); end; end')
    method.num_statements.should == 2
  end

  it 'counts 3 statements in a rescue' do
    method = process_method('def one() begin; callee(); callee(); callee(); rescue; callee(); callee(); callee(); end; end')
    method.num_statements.should == 6
  end

  it 'counts 1 statement in a when' do
    method = process_method('def one() case fred; when "hi"; callee(); end; end')
    method.num_statements.should == 1
  end

  it 'counts 3 statements in a when' do
    method = process_method('def one() case fred; when "hi"; callee(); callee(); when "lo"; callee(); end; end')
    method.num_statements.should == 3
  end

  it 'does not count empty case' do
    method = process_method('def one() case fred; when "hi"; ; when "lo"; ; end; end')
    method.num_statements.should == 0
  end

  it 'counts 1 statement in a block' do
    method = process_method('def one() fred.each do; callee(); end; end')
    method.num_statements.should == 1
  end

  # FIXME: I think this is wrong, but it specs current behavior.
  it 'counts 4 statements in a block' do
    method = process_method('def one() fred.each do; callee(); callee(); callee(); end; end')
    method.num_statements.should == 4
  end

  it 'counts 1 statement in a singleton method' do
    method = process_singleton_method('def self.foo; callee(); end')
    method.num_statements.should == 1
  end

  it 'counts else statement' do
    src = <<EOS
def parse(arg, argv, &error)
  if !(val = arg) and (argv.empty? or /\A-/ =~ (val = argv[0]))
    return nil, block, nil
  end
  opt = (val = parse_arg(val, &error))[1]
  val = conv_arg(*val)
  if opt and !arg
    argv.shift
  else
    val[0] = nil
  end
  val
end
EOS
    method = process_method(src)
    method.num_statements.should == 6
  end
end

describe TooManyStatements do
  before(:each) do
    @detector = TooManyStatements.new('silver')
  end

  it_should_behave_like 'SmellDetector'

  context 'when the method has 30 statements' do
    before :each do
      @num_statements = 30
      ctx = double('method_context').as_null_object
      ctx.should_receive(:num_statements).and_return(@num_statements)
      ctx.should_receive(:config).and_return({})
      @smells = @detector.examine_context(ctx)
    end
    it 'reports only 1 smell' do
      @smells.length.should == 1
    end
    it 'reports the number of statements' do
      @smells[0].smell[TooManyStatements::STATEMENT_COUNT_KEY].should == @num_statements
    end
    it 'reports the correct subclass' do
      @smells[0].subclass.should == TooManyStatements::SMELL_SUBCLASS
    end
  end
end
