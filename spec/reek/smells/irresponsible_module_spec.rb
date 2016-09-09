require_relative '../../spec_helper'
require_lib 'reek/smells/irresponsible_module'

RSpec.describe Reek::Smells::IrresponsibleModule do
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
        # Method is necessary because we don't count empty classes.
        def bravo; end
        class Charlie
        end
      end
    EOS

    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [1],
                           context: 'Alfa')
    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [4],
                           context: 'Alfa::Charlie')
  end

  %w(class module).each do |scope|
    it "reports a #{scope} without a comment" do
      src = <<-EOS
        #{scope} Alfa
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "does not report re-opened #{scope}" do
      src = <<-EOS
        # Abstract base
        #{scope} Alfa; end

        #{scope} Alfa; def bravo; end; end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "does not report a #{scope} having a comment" do
      src = <<-EOS
        # Do not report me
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
        # This is a valid comment

        require 'alfa'

        #{scope} Bravo
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with only a trailing comment" do
      src = <<-EOS
        #{scope} Alfa
        end # end scope
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "does not report #{scope} used only as namespaces" do
      src = <<-EOS
        #{scope} Alfa
          # Describes Bravo
          #{scope} Bravo
            def charlie
            end
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports #{scope} that have both a nested #{scope} and methods" do
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

    it "reports #{scope} that has both a nested #{scope} and singleton methods" do
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

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} defined through assignment" do
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
