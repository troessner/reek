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
    run_interactive("reek --no-color #{args}")
    type(stdin)
    close_input
  end

  def rake(name, task_def)
    header = <<-EOS.strip_heredoc
      require 'reek/rake/task'

    EOS
    write_file 'Rakefile', header + task_def
    run_simple("rake #{name}", false)
  end
end

World do
  ReekWorld.new
end

Before do
  @aruba_timeout_seconds = 30
end
