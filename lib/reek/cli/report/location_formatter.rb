module Reek
  module Cli
    module Report
      module BlankLocationFormatter
        def self.format(_warning)
          ''
        end
      end

      module DefaultLocationFormatter
        def self.format(warning)
          "#{warning.lines.inspect}:"
        end
      end

      module SingleLineLocationFormatter
        def self.format(warning)
          "#{warning.source}:#{warning.lines.first}: "
        end
      end
    end
  end
end
