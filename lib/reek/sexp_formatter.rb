module Reek
  class SexpFormatter
    def self.format(sexp)
      return sexp.to_s unless Array === sexp
      first = sexp[1]
      case sexp[0]
      when :array
        format_all(sexp, ', ')
      when :call
        meth, args = sexp[2..3]
        result = format(first)
        if meth.to_s == '[]'
          result += (args.nil? ? '[]' : "[#{format(args)}]")
        else
          result += ".#{meth}" + (args ? "(#{format(args)})" : '')
        end
        result
      when :colon2
        format_all(sexp, '::')
      when :const, :cvar, :dvar
        format(first)
      when :dot2
        format_all(sexp, '..')
      when :dstr
        '"' + format_all(sexp, '') + '"'
      when :evstr
        "\#\{#{format(first)}\}"
      when :fcall, :vcall
        args = sexp[2]
        result = first.to_s
        result += "(#{format(args)})" if args
        result
      when :iter
        'block'
      when :lasgn
        format_all(sexp, '=')
      when :nth_ref
        "$#{first}"
      when :str
        first
      when :xstr
        "`#{first}`"
      else
        sexp[-1].to_s
      end
    end
    
    def self.format_all(sexp, glue)
      sexp[1..-1].map {|arg| format(arg)}.join(glue)
    end
  end
end
