require File.join(File.dirname(File.expand_path(__FILE__)), 'source')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source_file')
require File.join(File.dirname(File.expand_path(__FILE__)), 'source_locator')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'sniffer')

#
# Extensions to +File+ needed by Reek.
#
class File
  #
  # Creates a new +Source+ that assumes this File contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  def to_reek_source
    Reek::SourceFile.new(path)
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
  def to_reek_source(description = 'io')
    Reek::Source.new(self.readlines.join, description)
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
  def to_reek_source
    Reek::Source.new(self, 'string')
  end
end
