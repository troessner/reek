class SomeClass
  def method_with_keyword_arguments(foo: '123')
    if foo == '123'
      bar
    else
      baz
    end
  end

  def make_symbol_list
    %i(foo bar baz)
  end

  def make_other_symbol_list
    %I(foo bar baz)
  end
end
