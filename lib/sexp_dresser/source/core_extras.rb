require 'sexp_dresser/source/source_code'

#
# Extensions to +File+ needed by SexpDresser.
#
class File
  #
  # Creates a new +Source+ that assumes this File contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [SexpDresser::Source::SourceFile]
  #
  def to_sexp_dresser_source
    SexpDresser::Source::SourceFile.new(path)
  end
end

#
# Extensions to +IO+ needed by SexpDresser.
#
class IO
  #
  # Creates a new +Source+ that assumes this IO stream contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [SexpDresser::Source::SourceCode]
  #
  def to_sexp_dresser_source(description = 'io')
    SexpDresser::Source::SourceCode.new(self.readlines.join, description)
  end
end

#
# Extensions to +String+ needed by SexpDresser.
#
class String
  #
  # Creates a new +Source+ that assumes this string contains Ruby source
  # code and prepares it to be examined for code smells.
  #
  # @return [SexpDresser::Source::SourceCode]
  #
  def to_sexp_dresser_source
    SexpDresser::Source::SourceCode.new(self, 'string')
  end
end
