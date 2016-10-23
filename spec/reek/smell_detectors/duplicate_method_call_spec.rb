require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/duplicate_method_call'

RSpec.describe Reek::SmellDetectors::DuplicateMethodCall do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo(charlie)
          charlie.delta
          charlie.delta
        end
      end
    EOS

    expect(src).to reek_of(:DuplicateMethodCall,
                           lines:   [3, 4],
                           context: 'Alfa#bravo',
                           message: "calls 'charlie.delta' 2 times",
                           source:  'string',
                           name:    'charlie.delta',
                           count:   2)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        def bravo(charlie)
          charlie.delta
          charlie.delta
        end

        def echo(foxtrot)
          foxtrot.golf
          foxtrot.golf
        end
      end
    EOS

    expect(src).
      to reek_of(:DuplicateMethodCall, lines: [3, 4], name: 'charlie.delta', count: 2).
      and reek_of(:DuplicateMethodCall, lines: [8, 9], name: 'foxtrot.golf', count: 2)
  end

  context 'with repeated method calls' do
    it 'reports repeated call to lvar' do
      src = 'def alfa(bravo); bravo.charlie + bravo.charlie; end'
      expect(src).to reek_of(:DuplicateMethodCall, name: 'bravo.charlie')
    end

    it 'reports call parameters' do
      src = 'def alfa; @bravo.charlie(2, 3) + @bravo.charlie(2, 3); end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@bravo.charlie(2, 3)')
    end

    it 'reports nested calls' do
      src = 'def alfa; @bravo.charlie.delta + @bravo.charlie.delta; end'
      expect(src).
        to reek_of(:DuplicateMethodCall, name: '@bravo.charlie').
        and reek_of(:DuplicateMethodCall, name: '@bravo.charlie.delta')
    end

    it 'ignores calls to new' do
      src = 'def alfa; @bravo.new + @bravo.new; end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated simple method calls' do
    it 'reports no smell' do
      src = <<-EOS
        def alfa
          bravo
          bravo
        end
      EOS

      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated simple method calls with blocks' do
    it 'reports a smell if the blocks are identical' do
      src = <<-EOS
        def alfa
          bravo { charlie }
          bravo { charlie }
        end
      EOS

      expect(src).to reek_of(:DuplicateMethodCall)
    end

    it 'reports no smell if the blocks are different' do
      src = <<-EOS
        def alfa
          bravo { charlie }
          bravo { delta }
        end
      EOS

      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated method calls with receivers with blocks' do
    it 'reports a smell if the blocks are identical' do
      src = <<-EOS
        def alfa
          bravo.charlie { delta }
          bravo.charlie { delta }
        end
      EOS

      expect(src).to reek_of(:DuplicateMethodCall)
    end

    it 'reports a smell if the blocks are different' do
      src = <<-EOS
        def alfa
          bravo.charlie { delta }
          bravo.charlie { echo }
        end
      EOS

      expect(src).to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated attribute assignment' do
    it 'reports repeated assignment' do
      src = <<-EOS
        def alfa(bravo)
          @charlie[bravo] = true
          @charlie[bravo] = true
        end
      EOS

      expect(src).to reek_of(:DuplicateMethodCall)
    end

    it 'does not report multi-assignments' do
      src = <<-EOS
        def alfa
          bravo, charlie = delta, echo
          charlie, bravo = delta, echo
        end
      EOS

      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'non-repeated method calls' do
    it 'does not report similar calls' do
      src = 'def alfa(bravo) bravo.charlie == self.charlie end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end

    it 'respects call parameters' do
      src = 'def alfa; @bravo.charlie(3) + @bravo.charlie(2) end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'allowing up to 3 calls' do
    let(:config) do
      { Reek::SmellDetectors::DuplicateMethodCall::MAX_ALLOWED_CALLS_KEY => 3 }
    end

    it 'does not report double calls' do
      src = 'def alfa(bravo); bravo.charlie + bravo.charlie; end'
      expect(src).not_to reek_of(:DuplicateMethodCall).with_config(config)
    end

    it 'does not report triple calls' do
      src = 'def alfa(bravo); bravo.charlie + bravo.charlie + bravo.charlie; end'
      expect(src).not_to reek_of(:DuplicateMethodCall).with_config(config)
    end

    it 'reports quadruple calls' do
      src = <<-EOS
        def alfa
          bravo.charlie + bravo.charlie + bravo.charlie + bravo.charlie
        end
      EOS

      expect(src).to reek_of(:DuplicateMethodCall,
                             count: 4).with_config(config)
    end
  end

  context 'allowing calls to some methods' do
    it 'does not report calls to some methods' do
      config = { Reek::SmellDetectors::DuplicateMethodCall::ALLOW_CALLS_KEY => ['@bravo.charlie'] }
      src = 'def alfa; @bravo.charlie + @bravo.charlie; end'
      expect(src).not_to reek_of(:DuplicateMethodCall).with_config(config)
    end

    it 'reports calls to other methods' do
      config = { Reek::SmellDetectors::DuplicateMethodCall::ALLOW_CALLS_KEY => ['@delta.charlie'] }
      src = 'def alfa; @bravo.charlie + @bravo.charlie; end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@bravo.charlie').with_config(config)
    end

    it 'does not report calls to methods specifed with a regular expression' do
      config = { Reek::SmellDetectors::DuplicateMethodCall::ALLOW_CALLS_KEY => [/charlie/] }
      src = 'def alfa; puts @bravo.charlie; puts @bravo.charlie; end'
      expect(src).not_to reek_of(:DuplicateMethodCall, name: '@bravo.charlie').with_config(config)
    end
  end
end
