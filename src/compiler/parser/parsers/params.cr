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
    method_def.return_type = parse_return_type

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

  def parse_param_list(into target : FuncDef)
    expect(Token::Type::LParen)
    skip_space_and_newlines
    unless accept(Token::Type::RParen)
      param_index = 0
      loop do
        skip_space_and_newlines
        next_param = parse_param
        skip_space_and_newlines
        target.params << next_param
        param_index += 1

        # if there is no comma, then this is the last param and expect a closing paren
        unless accept(Token::Type::Comma)
          expect(Token::Type::RParen)
          break
        end
      end
    end
  end

  def parse_param
    name = expect(Token::Type::Identifier)
    skip_space
    return_type = parse_return_type

    push_local_var(name.value)
    
    param = Param.new(name.value, return_type)
    param.at(name.location).at_end(return_type.location)
    param
  end

  def parse_return_type
    start = expect(Token::Type::Colon)
    skip_space
    name = expect(Token::Type::IdentifierU)
    ReturnType.new(name.value).at(start.location).at_end(name.location)
  end
end
