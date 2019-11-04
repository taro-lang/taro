require "spec"
require "./../src/compiler/lexer/*"

include Taro::Compiler

def tokenize(source : String, in_context : Lexer::Context? = nil)
  lexer = Lexer.new(IO::Memory.new(source), File.join(Dir.current, "test_source.taro"))
  if in_context
    lexer.push_context(in_context)
  end
  lexer.lex_all
  lexer.tokens
end
