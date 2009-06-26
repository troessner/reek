require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'

class CucumberWorld

  def run(args)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    @last_stdout = `ruby -Ilib bin/reek #{args} 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end
end

World do
  CucumberWorld.new
end
