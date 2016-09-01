require_relative '../../spec_helper'
require_lib 'reek/smells/control_parameter'

RSpec.describe Reek::Smells::ControlParameter do
  it 'reports the right values' do
    src = <<-EOS
      def alpha(bravo)
        bravo ? true : false
      end
    EOS

    expect(src).to reek_of(:ControlParameter,
                           lines:    [2],
                           context:  'alpha',
                           message:  'is controlled by argument bravo',
                           source:   'string',
                           argument: 'bravo')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alpha(bravo, charlie)
        bravo ? true : false
        charlie ? true : false
      end
    EOS

    expect(src).to reek_of(:ControlParameter, lines: [2], argument: 'bravo')
    expect(src).to reek_of(:ControlParameter, lines: [3], argument: 'charlie')
  end

  context 'parameter not used to determine code path' do
    it 'does not report a ternary check on an ivar' do
      src = 'def alpha(bravo) @charlie ? bravo : false end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report a ternary check on a lvar' do
      src = 'def alpha(bravo) charlie = 27; charlie ? bravo : @delta end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when parameter is unused' do
      src = 'def alpha(bravo) charlie = 1 end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when parameter is used inside conditional' do
      src = 'def alpha(bravo) if true then puts bravo end end'
      expect(src).not_to reek_of(:ControlParameter)
    end
  end

  context 'parameter only used to determine code path' do
    it 'reports a ternary check on a parameter' do
      src = 'def alpha(bravo); bravo ? true : false; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports a couple inside a block' do
      src = 'def alpha(bravo); charlie.map { |blk| bravo ? blk : "#{blk}" }; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on an if statement modifier' do
      src = 'def alpha(bravo); charlie if bravo; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on an unless statement modifier' do
      src = 'def alpha(bravo); charlie unless bravo; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression' do
      src = 'def alpha(bravo); if bravo then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with &&' do
      src = 'def alpha(bravo); if bravo && true then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with `and`' do
      src = 'def alpha(bravo); if bravo and true then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with preceding &&' do
      src = 'def alpha(bravo); if true && bravo then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with ||' do
      src = 'def alpha(bravo); if bravo || true then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with or' do
      src = 'def alpha(bravo); if bravo or true then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on if control expression with if' do
      src = 'def alpha(bravo); if (bravo if true) then charlie end; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on && notation' do
      src = 'def alpha(bravo); bravo && charlie; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on || notation' do
      src = 'def alpha(bravo); bravo || charlie; end'
      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on case statement' do
      src = <<-EOS
        def alpha(bravo)
          case bravo
          when nil then nil
          else false
          end
        end
      EOS

      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on nested if statements that are both control parameters' do
      src = <<-EOS
        def nested(bravo)
          if bravo
            charlie
            charlie if bravo
          end
        end
      EOS

      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on nested if statements where the inner if is a control parameter' do
      src = <<-EOS
        def nested(bravo)
          if true
            charlie
            charlie if bravo
          end
        end
      EOS

      expect(src).to reek_of(:ControlParameter, argument: 'bravo')
    end

    it 'reports on explicit comparison in the condition' do
      src = 'def alpha(bravo); if bravo == charlie then charlie end; end'
      expect(src).to reek_of(:ControlParameter)
    end

    it 'reports on explicit negative comparison in the condition' do
      src = 'def alpha(bravo); if bravo != charlie then charlie end; end'
      expect(src).to reek_of(:ControlParameter)
    end

    it 'reports when the argument is compared to a regexp' do
      src = 'def alpha(bravo); if bravo =~ charlie then charlie end; end'
      expect(src).to reek_of(:ControlParameter)
    end

    it 'reports when the argument is reverse-compared to a regexp' do
      src = 'def alpha(bravo); if /charlie/ =~ bravo then charlie end; end'
      expect(src).to reek_of(:ControlParameter)
    end

    it 'reports when the argument is used in a complex regexp' do
      src = 'def alpha(bravo); if /charlie#{bravo}/ =~ delta then charlie end; end'
      expect(src).to reek_of(:ControlParameter)
    end

    it 'reports when the argument is a block parameter' do
      src = <<-EOS
        def bravo(&blk)
          charlie(blk || proc {})
        end
      EOS
      expect(src).to reek_of(:ControlParameter)
    end
  end

  context 'parameter used besides determining code path' do
    it 'does not report on if conditional expression' do
      src = 'def alpha(bravo); if bravo then charlie(bravo); end end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report on an if statement modifier' do
      src = 'def alpha(bravo); charlie(bravo) if bravo; end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report on an unless statement modifier' do
      src = 'def alpha(bravo); charlie(bravo) unless bravo; end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report on if control expression with &&' do
      src = 'def alpha(bravo) if bravo && true then puts bravo end end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report on && notation' do
      src = 'def alpha(bravo); bravo && charlie(bravo); end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report on || notation' do
      src = 'def alpha(bravo); bravo || charlie(bravo) end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when parameter is used outside conditional' do
      src = 'def alpha(bravo) puts bravo; if bravo then charlie end; end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when parameter is used as a method call argument in a condition' do
      src = 'def alpha(bravo); if charlie(bravo) then delta end; end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when parameter is used as a method call receiver in a condition' do
      src = 'def alpha(bravo); if bravo.charlie? then delta end; end'
      expect(src).not_to reek_of(:ControlParameter)
    end

    it 'does not report when used in body of control flow operator' do
      src = <<-EOS
        def alpha(bravo)
          case bravo
          when :charlie
            puts 'charlie'
          else
            puts 'delta'
          end
          echo or foxtrot(bravo)
        end
      EOS

      expect(src).not_to reek_of(:ControlParameter)
    end
  end
end
