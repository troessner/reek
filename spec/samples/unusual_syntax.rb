class SomeClass
  def method_with_keyword_arguments(foo: '123')
    puts foo
  end

  def make_symbol_list
    %i(foo bar baz)
  end

  def make_other_symbol_list
    %I(foo bar baz)
  end

  def method_with_required_keyword_arguments(foo:)
    puts foo
  end

  def method_with_array_decomposition((a, b))
    puts "#{a}, #{b}"
  end
end
