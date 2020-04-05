module Taro::Compiler::Parser::Navigation
  def skip_space
    skip_tokens(Token::Type.whitespace)
  end

  def skip_space_and_newlines
    skip_tokens(Token::Type.whitespace + [Token::Type::NEWLINE])
  end

  private def skip_tokens(allowed)
    while allowed.includes?(@current_token.type)
      read_token
    end
    @current_token
  end

  def accept(*types : Token::Type)
    if types.includes?(@current_token.type)
      token = @current_token
      read_token
      return token
    end
  end

  def expect(*types : Token::Type)
    accept(*types) || raise ParseError.new(current_location, "Expected one of #{types.join(',')} but got #{@current_token.type}")
  end

  def accept_delimiter
    accept(Token::Type::SEMI, Token::Type::NEWLINE)
  end

  def expect_delimiter
    expect(Token::Type::SEMI, Token::Type::NEWLINE)
  end

  def expect_delimiter_or_eof
    expect(Token::Type::SEMI, Token::Type::NEWLINE, Token::Type::EOF)
  end
end
