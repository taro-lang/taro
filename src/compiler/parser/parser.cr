require "./ast/**"
require "./parsers/**"

module ::Taro::Compiler
  class Parser < Lexer
    def initialize(source : IO, source_file : String)
      super(source, source_file)
      @local_vars = [Set(String).new]
      read_token
    end

    def skip_space
      skip_tokens(Token::Type.whitespace)
    end

    def skip_space_and_newlines
      skip_tokens(Token::Type.whitespace + [Token::Type::NewLine])
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
      accept(Token::Type::Semi, Token::Type::NewLine)
    end

    def expect_delimiter
      expect(Token::Type::Semi, Token::Type::NewLine)
    end

    def expect_delimiter_or_eof
      expect(Token::Type::Semi, Token::Type::NewLine, Token::Type::Eof)
    end

    def parse
      program = Expressions.new
      skip_space_and_newlines
      until accept(Token::Type::Eof)
        program.children << parse_expression
        # Doc comments are not (can not be) delimited by newlines since they
        # do not have an explicit closing token, so skip the expectation of a
        # delimiter if the previous expression was a doc comment.
        # unless program.children.last.is_a?(DocComment)
          expect_delimiter_or_eof
        # end
        skip_space_and_newlines
      end

      program
    end

    def parse_expression
      case current_token.type
      # when Token::Type::DEF, Token::Type::DEFSTATIC
      #   parse_def
      when Token::Type::Module
        parse_module_def
        # when Token::Type::DEFTYPE
        #   parse_type_def
        # when Token::Type::FN
        #   parse_anonymous_function
        # when Token::Type::MATCH
        #   parse_match
        # when Token::Type::INCLUDE
        #   parse_include
        # when Token::Type::EXTEND
        #   parse_extend
        # when Token::Type::REQUIRE
        #   parse_require
        # when Token::Type::WHEN, Token::Type::UNLESS
        #   parse_conditional
        # when Token::Type::WHILE, Token::Type::UNTIL
        #   parse_loop
        # when Token::Type::AMPERSAND
        #   parse_function_capture
        # when Token::Type::MAGIC_FILE, Token::Type::MAGIC_LINE, Token::Type::MAGIC_DIR
        #   parse_magic_constant
        # when Token::Type::DOC_START
        #   parse_doc_comment
      else
        parse_module_def
      end
    end

    ###
    # Utilities
    #
    # Utility methods for managing the state of the parser or for making
    # complex assertions on values.
    ###

    def push_var_scope(scope = Set(String).new)
      @local_vars.push(scope)
    end

    def pop_var_scope
      @local_vars.pop
    end

    def push_local_var(name : String)
      @local_vars.last.add(name)
    end

    def is_local_var?(name : String)
      @local_vars.last.includes?(name)
    end

    # Returns true if the given identifier is modified (i.e., ends with a
    # `?` or `!`).
    def modified_ident?(ident : String)
      ident.ends_with?('?') || ident.ends_with?('!')
    end

    include Ast
    include Parsers
  end
end
