$:.unshift 'lib'

require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'
require 'reek'
require 'reek/adapters/application'

class CucumberWorld

  def run(args)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    @last_stdout = `ruby -Ilib bin/reek #{args} 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_with_pipe(stdin, args)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    @last_stdout = `echo \"#{stdin}\" | ruby -Ilib bin/reek #{args} 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end

  def rake
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    @last_stdout = `rake reek 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end
end

World do
  CucumberWorld.new
end
