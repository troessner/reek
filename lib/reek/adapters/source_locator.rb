
module Reek
  class SourceLocator
    def initialize(paths)
      @paths = paths
    end

    def all_sources
      valid_paths.map {|path| File.new(path).to_reek_source }
    end

    def all_sniffers
      all_sources.map {|src| Reek::Sniffer.new(src)}
    end

    def all_ruby_source_files(paths)
      paths.map do |path|
        if test 'd', path
          all_ruby_source_files(Dir["#{path}/**/*.rb"])
        else
          path
        end
      end.flatten.sort
    end

    def valid_paths
      all_ruby_source_files(@paths).select do |path|
        if test 'f', path
          true
        else
          $stderr.puts "Error: No such file - #{path}"
          false
        end
      end
    end
  end
end
