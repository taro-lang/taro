require "../../spec_helper"

describe Lexer do
  {% for type, token in STATIC_TOKENS %}
    it "lexes `" + {{token}} + "`" do
      assert_token_type {{token}}, {{type}}
    end
  {% end %}

  it "lexes multiple whitespace delimiters together" do
    tokens = tokenize(" \t\t ")
    tokens.size.should eq(2) # One whitespace token, followed by the EOF.
    tokens.first.type.should eq(Token::Type::Whitespace)
  end

  it "lexes newlines characters separately from whitespace" do
    tokens = tokenize(" \t\n ")
    tokens.size.should eq(4) # whitespace, newline, whitespace, EOF.
    tokens[0].type.should eq(Token::Type::Whitespace)
    tokens[1].type.should eq(Token::Type::NewLine)
    tokens[2].type.should eq(Token::Type::Whitespace)
  end

  it "stops lexing after reaching EOF" do
    tokens = tokenize("thing\0 more things")
    tokens.size.should eq(2)
    tokens.last.type.should eq(Token::Type::Eof)
  end

  describe "numbers" do
    it "lexes integers" do
      assert_token_type "1", Token::Type::Integer
      assert_token_type "100", Token::Type::Integer
      assert_token_type "123456789", Token::Type::Integer
      assert_token_type "123_456", Token::Type::Integer
      assert_token_type "23_000", Token::Type::Integer
      assert_token_type "45_00", Token::Type::Integer
    end

    it "lexes floats" do
      assert_token_type "1.0", Token::Type::Float
      assert_token_type "100.0", Token::Type::Float
      assert_token_type "12345.6789", Token::Type::Float
      assert_token_type "123_456.789", Token::Type::Float
      assert_token_type "23.123_456", Token::Type::Float
      assert_token_type "1000.000_0", Token::Type::Float
    end

    it "lexes negative numbers" do
      assert_token_type "-1", Token::Type::Integer
      assert_token_type "-1.1", Token::Type::Float
    end
  end

  describe "strings" do
    it "lexes simple strings" do
      assert_token_type %q("hello, world"), Token::Type::String
    end

    it "allows empty double quoted strings" do
      assert_token_type %q(""), Token::Type::String
    end

    it "allows empty strings with whitespace" do
      assert_token_type %q("    "), Token::Type::String
    end

    it "allows literal newlines" do
      assert_token_type %q("hello,
      world"), Token::Type::String
    end

    ['"', '0', 't', 'n', '\\'].each do |escape|
      it "allows #{escape} as an escape sequence" do
        assert_token_type %Q("\\#{escape}"), Token::Type::String
      end
    end
  end

  describe "char literals" do
    it "lexes a char literal" do
      assert_token_type "'c'", Token::Type::Char
    end
    it "char literal should only accept one character" do
      expect_raises Exception, "Error char literal must be a single character - but got: `cc`" do 
        assert_token_type "'cc'", Token::Type::Char
      end
    end
  end

  describe "comments" do
    it "lexes single line comments" do
      assert_token_type "-- hello", Token::Type::Comment
    end
  end
end

private def assert_token_type(source, token_type, in_context : Lexer::Context? = nil)
  token = tokenize(source, in_context).first
  token.type.should eq(token_type)
end
