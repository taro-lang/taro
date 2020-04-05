module Taro::Compiler
  class Parser < Lexer
    def initialize(source : IO, source_file : String)
      super(source, source_file)
      read_token
    end

    include Parser::Navigation
  end
end
