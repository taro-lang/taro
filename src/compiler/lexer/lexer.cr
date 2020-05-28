require "./analyzer"
require "./token"
require "../location"
require "../exceptions"

module ::Taro::Compiler
  class Lexer
    enum Context
      Initial
      String
      CharLiteral
    end

    property analyzer : Analyzer
    property source_file : String
    property row : Int32
    property column : Int32
    property last_char : Char
    property current_token : Token
    property tokens : Array(Token)
    property context_stack : Array(Context)
    property brace_stack : Array(Char)

    def initialize(source : IO, source_file : String, row_start = 0, column_start = 0)
      @analyzer = Analyzer.new(source)
      @source_file = File.expand_path(source_file)
      @last_char = ' '
      @row = row_start
      @column = column_start
      @current_token = advance_token
      @buffer = IO::Memory.new
      @tokens = [] of Token
      @context_stack = [Context::Initial]
      @brace_stack = [] of Char
    end

    def lex_all
      until @current_token.type == Token::Type::Eof
        read_token
      end
    end

    # Move to a new token with a new buffer.
    def advance_token
      @current_token = Token.new(location: Location.new(@source_file, @row, @column))
    end

    def token_is_empty?
      @analyzer.buffer_value.empty?
    end

    def current_char : Char
      @analyzer.current_char
    end

    def current_location
      @current_token.location
    end

    # Consume a single character from the source.
    def read_char(save_in_buffer = true) : Char
      last_char = current_char
      if last_char == '\n'
        @row += 1
        @column = 0
      end

      @column += 1
      @current_token.location.length += 1

      @analyzer.read_char(save_in_buffer)
    end

    def skip_char : Char
      @analyzer.skip_last_char
      read_char
    end

    def peek_char : Char
      @analyzer.peek_char
    end

    def finished? : Bool
      @analyzer.finished?
    end

    def push_brace(type : Symbol)
      brace_to_push =
        case type
        when :paren        then '('
        when :square       then '['
        when :curly        then '{'
        when :single_quote then '\''
        when :double_quote then '"'
        else
          raise "Lexer bug: Attempted to push unknown brace type `#{type}`."
        end

      @brace_stack.push(brace_to_push)
    end

    # Attempts to pop the top bracing character from the stack, but only if it
    # matches the given type. Returns false if the type does not match.
    def pop_brace(type : Symbol)
      brace_to_pop =
        case type
        when :paren        then '('
        when :square       then '['
        when :curly        then '{'
        when :single_quote then '\''
        when :double_quote then '"'
        else
          raise "Lexer bug: Attempted to pop unknown brace type `#{type}`."
        end

      if current_brace == brace_to_pop
        @brace_stack.pop
      else
        return false
      end
    end

    def current_brace : Char
      @brace_stack.last? || '\0'
    end

    def push_context(context : Context)
      @context_stack.push(context)
    end

    def pop_context
      @context_stack.pop
    end

    def current_context
      @context_stack.last
    end

    def read_token
      advance_token

      case current_context
      when Context::Initial
        read_normal_token
      when Context::String
        read_string_token
      when Context::CharLiteral
        read_char_literal_token
      end

      finalize_token
    end

    def finalize_token
      @current_token.raw = @analyzer.buffer_value

      @analyzer.buffer.clear
      @analyzer.buffer << current_char

      @tokens << @current_token
      @current_token
    end

    def read_normal_token
      @current_token.type = Token::Type::Identifier

      case current_char
      when '\0'
        @current_token.type = Token::Type::Eof
        read_char
      when ','
        @current_token.type = Token::Type::Comma
        read_char
      when '.'
        @current_token.type = Token::Type::Point
        read_char
      when '&'
        @current_token.type = Token::Type::Ampersand
        read_char
        if current_char == '&'
          @current_token.type = Token::Type::AndAnd
          read_char
        end
      when '|'
        @current_token.type = Token::Type::Pipe
        read_char
        if current_char == '|'
          @current_token.type = Token::Type::OrOr
          read_char
        end
      when '='
        @current_token.type = Token::Type::Assign
        read_char
        case current_char
        when '='
          @current_token.type = Token::Type::Equal
          read_char
        else
          # do nothing to satify compiler warning
        end
      when '!'
        @current_token.type = Token::Type::Not
        read_char
        if current_char == '='
          @current_token.type = Token::Type::NotEqual
          read_char
        end
      when '<'
        @current_token.type = Token::Type::Less
        read_char
        case current_char
        when '='
          @current_token.type = Token::Type::LessEqual
          read_char
        when '-'
          @current_token.type = Token::Type::LArrow
          read_char
        else
          # do nothing to satify compiler warning
        end
      when '>'
        @current_token.type = Token::Type::Greater
        read_char
        if current_char == '='
          @current_token.type = Token::Type::GreaterEqual
          read_char
        end
      when '+'
        @current_token.type = Token::Type::Plus
        read_char
      when '-'
        @current_token.type = Token::Type::Minus
        read_char
        case current_char
        when .ascii_number?
          consume_numeric
        when '>'
          @current_token.type = Token::Type::RArrow
          read_char
        when '-'
          @current_token.type = Token::Type::Comment
          consume_single_line_comment
        else
          # do nothing to remove compiler warning
        end
      when '*'
        @current_token.type = Token::Type::Asterisk
        read_char
        if current_char == '*'
          @current_token.type = Token::Type::Pow
          read_char
        end
      when '/'
        @current_token.type = Token::Type::Slash
        read_char
      when '%'
        @current_token.type = Token::Type::Modulo
        read_char
      when '\n'
        @current_token.type = Token::Type::NewLine
        read_char
      when '"'
        skip_char
        push_brace(:double_quote)
        push_context(Context::String)
        read_string_token
      when '\''
        skip_char
        push_brace(:single_quote)
        push_context(Context::CharLiteral)
        read_char_literal_token
      when ':'
        @current_token.type = Token::Type::Colon
        read_char
      when ';'
        @current_token.type = Token::Type::Semi
        read_char
      when '('
        push_brace(:paren)
        @current_token.type = Token::Type::LParen
        read_char
      when ')'
        pop_brace(:paren)
        @current_token.type = Token::Type::RParen
        read_char
      when '['
        push_brace(:square)
        @current_token.type = Token::Type::LSquare
        read_char
      when ']'
        pop_brace(:square)
        @current_token.type = Token::Type::RSquare
        read_char
      when '{'
        push_brace(:curly)
        @current_token.type = Token::Type::LCurly
        read_char
      when '}'
        pop_brace(:curly)
        @current_token.type = Token::Type::RCurly
        read_char
      when .ascii_number?
        consume_numeric
      when .ascii_whitespace?
        consume_whitespace
      when .ascii_uppercase?
        consume_identifier_u
      else
        consume_identifier
        check_for_keyword
      end
    end

    def check_for_keyword
      if kw_type = Token::Type.keyword_map[@analyzer.buffer_value]?
        @current_token.type = kw_type
      end
    end

    def consume_numeric
      has_decimal = false

      loop do
        case current_char
        when '.'
          if !has_decimal && peek_char.ascii_number?
            read_char
            has_decimal = true
          else
            assign_numeric_value(has_decimal)
            break
          end
        when '_'
          read_char
        when .ascii_number?
          read_char
        else
          break
        end
      end

      assign_numeric_value(has_decimal)
    end

    private def assign_numeric_value(has_decimal)
      @current_token.value = @analyzer.buffer_value.tr("_", "")
      @current_token.type = has_decimal ? Token::Type::Float : Token::Type::Integer
    end

    def consume_whitespace
      @current_token.type = Token::Type::Whitespace
      while (c = read_char).ascii_whitespace? && c != '\n'; end
    end

    def consume_single_line_comment
      # If the first character of the comment is a space, it is ignored. Since
      # standard comments are written with a padding space (`-- comment`), the
      # actual content of the comment should not include that space.
      if current_char == ' '
        skip_char
      end
      until ['\n', '\0'].includes?(current_char)
        read_char
      end
    end

    def consume_identifier
      unless current_char.ascii_letter? || current_char == '_'
        raise "Unexpected character `#{current_char}` for Identifier. Current buffer: `#{@analyzer.buffer_value}`."
        # raise SyntaxError.new(current_location, "Unexpected character `#{current_char}` for Identifier. Current buffer: `#{@analyzer.buffer_value}`.")
      end

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      @current_token.value = @analyzer.buffer_value
    end

    def consume_identifier_u
      # IdentifierU must start with an uppercase character, and may only contain
      # letters, numbers or underscores afterwards.
      if current_char.ascii_uppercase?
        read_char
      else
        raise SyntaxError.new(current_location, "Unexpected character `#{current_char}` for IdentifierU. Current buffer: `#{@analyzer.buffer_value}`.")
      end

      @current_token.type = Token::Type::IdentifierU

      loop do
        if current_char.ascii_alphanumeric? || current_char == '_'
          read_char
        else
          break
        end
      end

      @current_token.value = @analyzer.buffer_value
    end

    def read_char_literal_token
      @current_token.type = Token::Type::Char
      count = 0
      loop do
        raise "Error char literal must be a single character - but got: `#{@analyzer.buffer_value}`" if count > 1
        case current_char
        when '\0'
          # raise SyntaxError.new(current_location, "Unterminated char literal. Reached EOF without terminating.")
          raise "Unterminated char literal. Reached EOF without terminating."
        when '\''
          skip_char
          if pop_brace(:single_quote)
            pop_context
            break
          end
        else
          read_char
          count += 1
        end
      end
    end

    def read_string_token
      @current_token.type = Token::Type::String

      # If the first characters of the token are an interpolation, push that
      # context and return an Interpol_Start token.
      # if current_char == '$'
      #   @current_token.type = Token::Type::Interpol_Start
      #   read_char
      #   read_char
      #   push_context(Context::Interpol)
      #   return
      # end

      # Otherwise, parse until either an interpolation or ending quote is
      # encountered.
      loop do
        case current_char
        when '\0'
          # A null character within a string literal is a syntax error.
          # raise SyntaxError.new(current_location, "Unterminated string literal. Reached EOF without terminating.")
          raise "Unterminated string literal. Reached EOF without terminating."
        when '\\'
          # Read two characters to naively support escaped characters.
          # This ensures that escaped quotes do not terminate the string.
          read_char
          read_char
          # when '$'
          #   # Don't actually consume the start of the interpolation yet. It will
          #   # be consumed by the next read.
          #   if peek_char == '('
          #     break
          #   end
          #   read_char
        when '"'
          skip_char
          if pop_brace(:double_quote)
            pop_context
            break
          end
        else
          read_char
        end
      end

      replace_escape_characters(@analyzer.buffer_value)
    end

    def replace_escape_characters(raw)
      # Replace escape codes
      @current_token.value = raw.gsub(/\\./) do |code|
        case code
        when "\\n"  then '\n'
        when "\\\"" then '"'
        when "\\t"  then '\t'
        when "\\e"  then '\e'
        when "\\r"  then '\r'
        when "\\f"  then '\f'
        when "\\v"  then '\v'
        when "\\b"  then '\b'
        when "\\0"  then '\0'
        else
          # do nothing
        end
      end
    end
  end
end
