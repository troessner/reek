require_relative '../../lib/reek'
require_relative '../../lib/reek/cli/application'
require 'aruba/cucumber'
require 'active_support/core_ext/string/strip'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

#
# Provides runner methods used in the cucumber steps.
#
class ReekWorld
  def reek(args)
    run_simple("reek --no-color #{args}", false)
  end

  def reek_with_pipe(stdin, args)
    run "reek --no-color #{args}"
    type(stdin)
    close_input
  end
end

World do
  ReekWorld.new
end

Before do
  Aruba.configure do |config|
    config.exit_timeout = 30
  end
end
