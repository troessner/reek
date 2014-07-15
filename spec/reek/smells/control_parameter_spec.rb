require 'spec_helper'
require 'reek/smells/control_parameter'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

describe ControlParameter do
  before(:each) do
    @source_name = 'lets get married'
    @detector = ControlParameter.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  it 'should not report a ternary check on an ivar' do
    src = 'def simple(arga) @ivar ? arga : 3 end'
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report a ternary check on a lvar' do
    src = 'def simple(arga) lvar = 27; lvar ? arga : @ivar end'
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report when parameter is unused' do
    src = 'def simple(arg) test = 1 end'
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report when parameter is used inside conditional' do
    src = 'def simple(arg) if true then puts arg end end'
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report when used in first conditional but not second' do
    src = <<EOS
def things(arg)
  if arg
    puts arg
  end
  if arg
    puts 'a'
  end
end
EOS
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report when used in second conditional but not first' do
    src = <<EOS
def things(arg)
  if arg
    puts 'a'
  end
  if arg
    puts arg
  end
end
EOS
    expect(src).not_to smell_of(ControlParameter)
  end

  it 'should not report on complex non smelly method' do
    src = <<EOS
  def self.guess(arg)
    case arg
    when ""
      t = self
    when "a"
      t = Switch::OptionalArgument
    when "b"
      t = Switch::PlacedArgument
    else
      t = Switch::RequiredArgument
    end
    self >= t or incompatible_argument_styles(arg, t)
    t
  end
EOS
    expect(src).not_to smell_of(ControlParameter)
  end

  context 'parameter only used to determine code path' do
    it 'should report a ternary check on a parameter' do
      src = 'def simple(arga) arga ? @ivar : 3 end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arga')
    end

    it 'should spot a couple inside a block' do
      src = 'def blocks(arg) @text.map { |blk| arg ? blk : "#{blk}" } end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on an if statement modifier' do
      src = 'def simple(arg) args = {}; args.merge(\'a\' => \'A\') if arg end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on an unless statement modifier' do
      src = 'def simple(arg) args = {}; args.merge(\'a\' => \'A\') unless arg end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on if control expression' do
      src = 'def simple(arg) args = {}; if arg then args.merge(\'a\' => \'A\') end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on if control expression with &&' do
      src = 'def simple(arg) if arg && true then puts "arg" end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on if control expression with preceding &&' do
      src = 'def simple(arg) if true && arg then puts "arg" end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on if control expression with two && conditions' do
      src = 'def simple(a) ag = {}; if a && true && true then puts "2" end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'a')
    end

    it 'should report on if control expression with ||' do
      src = 'def simple(arg) args = {}; if arg || true then puts "arg" end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on if control expression with or' do
      src = 'def simple(arg) args = {}; if arg or true then puts "arg" end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on && notation' do
      src = 'def simple(arg) args = {}; arg && args.merge(\'a\' => \'A\') end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on || notation' do
      src = 'def simple(arg) args = {}; arg || args.merge(\'a\' => \'A\') end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on case statement' do
      src = 'def simple(arg) case arg when nil; nil when false; nil else nil end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report when the argument is a hash on which we access a key' do
      src = 'def simple(arg) if arg[\'a\'] then puts \'a\' else puts \'b\' end end'
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on nested if statements that are both control parameters' do
      src = <<EOS
def nested(arg)
  if arg
    puts 'a'
    puts 'b' if arg
  end
end
EOS
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end

    it 'should report on nested if statements where the inner if is a control parameter' do
      src = <<EOS
def nested(arg)
  if true
    puts 'a'
    puts 'b' if arg
  end
end
EOS
      expect(src).to smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end
  end

  context 'parameter used besides determining code path' do
    it 'should not report on if conditional expression' do
      src = 'def simple(arg) if arg then use(arg) else use(@other) end end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on an if statement modifier' do
      src = 'def simple(arg) args = {}; args.merge(\'a\' => arg) if arg end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on an unless statement modifier' do
      src = 'def simple(arg) args = {}; args.merge(\'a\' => arg) unless arg end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on if control expression' do
      src = 'def simple(arg) args = {}; if arg then args.merge(\'a\' => arg) end end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on if control expression with &&' do
      src = 'def simple(arg) if arg && true then puts arg end end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on && notation' do
      src = 'def simple(arg) args = {}; arg && args.merge(\'a\' => arg) end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report on || notation' do
      src = 'def simple(arg) args = {}; arg || args.merge(\'a\' => arg) end'
      expect(src).not_to smell_of(ControlParameter)
    end

    it 'should not report when parameter is used outside conditional' do
      src = 'def simple(arg) puts arg; if arg then @a = 1 end end'
      expect(src).not_to smell_of(ControlParameter)
    end
  end

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def things(arg)
  @text.map do |blk|
    arg ? blk : "blk"
  end
  puts "hello" if arg
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine(ctx)
      expect(smells.length).to eq(1)
      @warning = smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'has the correct fields' do
      expect(@warning.smell[ControlParameter::PARAMETER_KEY]).to eq('arg')
      expect(@warning.lines).to eq([3, 5])
    end
  end
end
