require 'English'
require 'tempfile'
require 'fileutils'
require 'open3'
require 'reek/cli/application'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

class ReekWorld
  def run(cmd)
    stderr_file = Tempfile.new('reek-world')
    stderr_file.close
    @last_stdout = `#{cmd} 2> #{stderr_file.path}`
    @last_exit_status = $CHILD_STATUS.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end

  def reek(args)
    run("ruby -Ilib bin/reek --no-color #{args}")
  end

  def reek_with_pipe(stdin, args)
    run("echo \"#{stdin}\" | ruby -Ilib bin/reek --no-color #{args}")
  end

  def rake(name, task_def)
    header = <<EOS
$:.unshift('lib')
require 'reek/rake/task'

EOS
    rakefile = Tempfile.new('rake_task', '.')
    rakefile.puts(header + task_def)
    rakefile.close
    run("rake -f #{rakefile.path} #{name}")
    lines = @last_stdout.split("\n")
    if lines.length > 0 && lines[0] =~ /^\(/
      @last_stdout = lines[1..-1].join("\n")
    end
  end
end

World do
  ReekWorld.new
end
