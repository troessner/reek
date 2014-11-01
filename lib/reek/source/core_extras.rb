require 'reek/source/source_code'

#
# Extensions to +File+ needed by Reek.
#
class File
  #
  # Creates a new +Source+ that assumes this File contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [Reek::Source::SourceFile]
  #
  def to_reek_source
    Reek::Source::SourceFile.new(path)
  end
end

#
# Extensions to +IO+ needed by Reek.
#
class IO
  #
  # Creates a new +Source+ that assumes this IO stream contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [Reek::Source::SourceCode]
  #
  def to_reek_source(description = 'io')
    Reek::Source::SourceCode.new(readlines.join, description)
  end
end

#
# Extensions to +String+ needed by Reek.
#
class String
  #
  # Creates a new +Source+ that assumes this string contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [Reek::Source::SourceCode]
  #
  def to_reek_source
    Reek::Source::SourceCode.new(self, 'string')
  end
end
