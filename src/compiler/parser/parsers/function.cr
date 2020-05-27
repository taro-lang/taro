module ::Taro::Compiler::Parsers
  def parse_function_def
    start = expect(Token::Type::Def)
    skip_space
    name = expect(Token::Type::Identifier).value

    method_def = FuncDef.new(name).at(start.location)
    push_var_scope

    skip_space
    parse_param_list(into: method_def)

    skip_space
    # TODO - parse types 
    # List or Map or Record or Function or Enum
    # e.g. 
    # foo : User,  foo : List[User], foo : Map[String, User],  foo : Int -> String, foo : Map[String, Int -> String]
    method_def.return_type = parse_type_restriction 

    skip_space_and_newlines
    expect(Token::Type::LCurly)
    skip_space_and_newlines

    if finish = accept(Token::Type::RCurly)
      method_def.body = Nop.new
      pop_var_scope
      return method_def.at_end(finish.location)
    else
      method_def.body = parse_code_block(Token::Type::RCurly)
      finish = expect(Token::Type::RCurly)
      pop_var_scope
      return method_def.at_end(finish.location)
    end
  end
end
