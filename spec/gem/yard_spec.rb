require_relative '../spec_helper'
require 'tempfile'

RSpec.describe 'yardoc' do
  before :each do
    stderr_file = Tempfile.new('yardoc')
    stderr_file.close
    @stdout = `yardoc 2> #{stderr_file.path}`
    @stderr = IO.read(stderr_file.path)
  end
  it 'raises no warnings' do
    expect(@stderr).to eq('')
  end
end
