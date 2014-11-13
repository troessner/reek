require 'tempfile'
require 'fileutils'
require 'open3'
require 'reek/cli/application'

class ReekWorld
  def run(cmd)
    out, err, status = Open3.capture3(cmd)
    @last_stdout = out
    @last_stderr = err
    @last_exit_status = status.exitstatus
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
