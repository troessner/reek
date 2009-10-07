$:.unshift 'lib'

require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'
require 'reek'
require 'reek/adapters/application'

class ReekWorld
  def run(cmd)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    @last_stdout = `#{cmd} 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end

  def reek(args)
    run("ruby -Ilib bin/reek #{args}")
  end

  def reek_with_pipe(stdin, args)
    run("echo \"#{stdin}\" | ruby -Ilib bin/reek #{args}")
  end

  def rake
    run("rake reek")
  end
end

World do
  ReekWorld.new
end
