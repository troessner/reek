require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/app_configuration'
require_relative '../../../lib/reek/source/source_locator'

RSpec.describe Reek::Source::SourceLocator do
  let(:source_locator) { described_class.new([path]) }
  let(:pathname) { Pathname.new(path) }
  let(:path) { 'lib/reek/smells.rb' }

  subject { source_locator }
  it { is_expected.to be_a_kind_of(Enumerable) }
  it { is_expected.to include(pathname) }
end
