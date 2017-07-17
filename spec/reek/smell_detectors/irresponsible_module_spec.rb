require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/irresponsible_module'

RSpec.describe Reek::SmellDetectors::IrresponsibleModule do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
      end
    EOS

    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has no descriptive comment',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        # Method is necessary because we don't count namespace classes.
        def bravo; end
        class Charlie
        end
      end
    EOS

    expect(src).
      to reek_of(:IrresponsibleModule, lines: [1], context: 'Alfa').
      and reek_of(:IrresponsibleModule, lines: [4], context: 'Alfa::Charlie')
  end

  %w(class module).each do |scope|
    it "reports a #{scope} without a comment" do
      src = <<-EOS
        #{scope} Alfa
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "does not report a #{scope} having a comment" do
      src = <<-EOS
        # Do not report me, I'm responsible!
        #{scope} Alfa; end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with an empty comment" do
      src = <<-EOS
        #
        #
        #
        #{scope} Alfa; end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with a preceding comment with intermittent material" do
      src = <<-EOS
        # This is a comment that should not be related to Bravo

        require 'alfa'

        #{scope} Bravo
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with only a trailing comment" do
      src = <<-EOS
        #{scope} Alfa
        end # This belongs to Alfa but doesn't count
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "does not report #{scope} used only as a namespace" do
      src = <<-EOS
        #{scope} Alfa
          # Describes Bravo
          #{scope} Bravo
            def charlie
            end
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "does not report #{scope} used only as a namespace for several nested moduless" do
      src = <<-EOS
        #{scope} Alfa
          # Describes Bravo
          class Bravo
            def charlie
            end
          end

          # Describes Delta
          module Delta
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "reports #{scope} that is used as a namespace but also has methods" do
      src = <<-EOS
        #{scope} Alfa
          def bravo
          end

          # Describes Charlie
          #{scope} Charlie
          end
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "reports #{scope} that is used as a namespace but also has singleton methods" do
      src = <<-EOS
        #{scope} Alfa
          def self.bravo
          end

          # Describes Charlie
          #{scope} Charlie
          end
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "does not report a namespace #{scope} that has a nested class through assignment" do
      src = <<-EOS
        #{scope} Alfa
          # Bravo is responsible
          Bravo = Class.new Charlie do
            def delta; end
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "does not report #{scope} only containing constants" do
      src = <<-EOS
        #{scope} Alfa
          Bravo = 23
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "reports #{scope} that contains method calls" do
      src = <<-EOS
        #{scope} Alfa
          bravo :charlie
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "reports #{scope} that contains non-constant assignments" do
      src = <<-EOS
        #{scope} Alfa
          bravo = charlie
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa')
    end

    it "reports an irresponsible #{scope} defined through assignment" do
      src = <<-EOS
        # Alfa is responsible, but Bravo is not
        #{scope} Alfa
          Bravo = Class.new Charlie # Only "class" is supposed to reek here.
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa::Bravo')
    end

    it 'reports structs defined through assignment' do
      src = <<-EOS
        # Alfa is responsible, but Bravo is not
        #{scope} Alfa
          Bravo = Struct.new(:charlie)
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Alfa::Bravo')
    end

    it 'does not report constants that are not classes' do
      src = <<-EOS
        # Alfa is responsible
        #{scope} Alfa
          Bravo = 23
          Charlie = Hash.new
          Delta = ''.freeze
          Echo = Class.new.new
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end
  end
end
