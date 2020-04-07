module ::Taro::Compiler::Parsers
  def parse_module_def
    start = expect(Token::Type::Module)
    skip_space
    name = expect(Token::Type::IdentifierU).value
    skip_space_and_newlines
    expect(Token::Type::LCurly)
    skip_space_and_newlines

    if finish = accept(Token::Type::RCurly)
      return ModuleDef.new(name, Nop.new).at(start.location).at_end(finish.location)
    else
      push_var_scope
      body = parse_code_block(Token::Type::RCurly)
      finish = expect(Token::Type::RCurly)
      pop_var_scope
      return ModuleDef.new(name, body).at(start.location).at_end(finish.location)
    end
  end

end
