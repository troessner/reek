require_relative '../../spec_helper'
require_lib 'reek/smells/irresponsible_module'

RSpec.describe Reek::Smells::IrresponsibleModule do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
      end
    EOS

    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [1],
                           context: 'Dummy',
                           message: 'has no descriptive comment',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Outer
        # Method is necessary because we don't count empty classes.
        def something; end
        class Inner
        end
      end
    EOS

    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [1],
                           context: 'Outer')
    expect(src).to reek_of(:IrresponsibleModule,
                           lines:   [4],
                           context: 'Outer::Inner')
  end

  %w(class module).each do |scope|
    it "reports a #{scope} without a comment" do
      src = <<-EOS
        #{scope} Dummy
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "does not report re-opened #{scope}" do
      src = <<-EOS
        # Abstract base
        #{scope} C; end

        #{scope} C; def foo; end; end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "does not report a #{scope} having a comment" do
      src = <<-EOS
        # Do not report me
        #{scope} Responsible; end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with an empty comment" do
      src = <<-EOS
        #
        #
        #
        #{scope} Dummy; end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with a preceding comment with intermittent material" do
      src = <<-EOS
        # This is a valid comment

        require 'something'

        #{scope} Dummy; end
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} with a trailing comment" do
      src = <<-EOS
        #{scope} Dummy
        end # end scope
      EOS

      expect(src).to reek_of(:IrresponsibleModule)
    end

    it "reports a fully qualified #{scope} name correctly" do
      src = <<-EOS
        #{scope} Other::Dummy
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Other::Dummy')
    end

    it "does not report #{scope} used only as namespaces" do
      src = <<-EOS
        #{scope} Outer
          # Describes Dummy
          #{scope} Dummy
            def baz
            end
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports #{scope} that have both a nested #{scope} and methods" do
      src = <<-EOS
        #{scope} Outer
          def something
          end
          # Describes Dummy
          #{scope} Dummy
          end
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Outer')
    end

    it "reports #{scope} that has both a nested #{scope} and singleton methods" do
      src = <<-EOS
        #{scope} Outer
          def self.something
          end
          # Describes Dummy
          #{scope} Dummy
          end
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Outer')
    end

    it "does not report a namespace #{scope} that has a nested #{scope} through assignment" do
      src = <<-EOS
        #{scope} Outer
          # Dummy is responsible
          Dummy = Class.new SuperDummy do
            def something; end
          end
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end

    it "reports a #{scope} defined through assignment" do
      src = <<-EOS
        # Outer is responsible, but Dummy is not
        #{scope} Outer
          Dummy = Class.new Bar # Only "class" is supposed to reek here.
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Outer::Dummy')
    end

    it 'reports structs defined through assignment' do
      src = <<-EOS
        # Outer is responsible, but Dummy is not
        #{scope} Outer
          Dummy = Struct.new(:x, :y)
        end
      EOS

      expect(src).to reek_of(:IrresponsibleModule, context: 'Outer::Dummy')
    end

    it 'does not report constants that are not classes' do
      src = <<-EOS
        #{scope} Qux
          Foo = 23
          Bar = Hash.new
          Quuz = 'foo'.freeze
          Zyxxy = Class.new.new
        end
      EOS

      expect(src).not_to reek_of(:IrresponsibleModule)
    end
  end
end
