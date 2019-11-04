require "../../spec_helper"

describe Lexer do
  it "lexes ok" do
    assert_token_type("(", Token::Type::LParen)
  end
end

private def assert_token_type(source, token_type, in_context : Lexer::Context? = nil)
  token = tokenize(source, in_context).first
  token.type.should eq(token_type)
end
