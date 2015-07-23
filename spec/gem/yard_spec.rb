require 'open3'
require_relative '../spec_helper'

RSpec.describe 'yardoc' do
  it 'executes successfully with no warnings' do
    stdout, stderr, status = Open3.capture3('yardoc')
    expect(stdout).to_not include('[warn]')
    expect(stderr).to be_empty
    expect(status).to be_success
  end
end
