module Reek
  class SexpFormatter
    def self.format(sexp)
      return sexp.to_s unless Array === sexp
      first = sexp[1]
      second = sexp[2]
      third = sexp[3]
      case sexp[0]
      when :array
        format_all(sexp, ', ')
      when :attrasgn
        result = format(first)
        if second == :[]=
          result += "[#{format(third[1])}] = #{format(third[2])}"
        end
        result
      when :call
        result = format(first)
        if second.to_s == '[]'
          result += (third.nil? ? '[]' : "[#{format(third)}]")
        else
          result += ".#{second}" + (third ? "(#{format(third)})" : '')
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
        result = first.to_s
        result += "(#{format(second)})" if second
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
