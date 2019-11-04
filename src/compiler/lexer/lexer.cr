require "./analyzer"
require "./token"

module ::Taro::Compiler
  class Lexer
    enum Context
      Initial
      String
    end

    property analyzer : Analyzer
    property source_file : String
    property row : Int32
    property column : Int32
    property last_char : Char 
    property current_token : Token 
    property tokens : Array(Token) 
    property context_stack : Array(Context)

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
      # when Context::String
      #   read_string_token
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
        if current_char == '='
          @current_token.type = Token::Type::LessEqual
          read_char
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
      when '*'
        @current_token.type = Token::Type::Asterisk
        read_char
      when '/'
        @current_token.type = Token::Type::Slash
        read_char
      when '%'
        @current_token.type = Token::Type::Modulo
        read_char
      when '\n'
        @current_token.type = Token::Type::NewLine
        read_char
        # when '"'
        #   skip_char
        #   push_context(Context::String)
        #   read_string_token
      when ':'
        @current_token.type = Token::Type::Colon
        read_char
      when ';'
        @current_token.type = Token::Type::Semi
        read_char
      when '('
        @current_token.type = Token::Type::LParen
        read_char
      when ')'
        @current_token.type = Token::Type::RParen
        read_char
      when '['
        @current_token.type = Token::Type::LBracket
        read_char
      when ']'
        @current_token.type = Token::Type::RBracket
        read_char
      when '{'
        @current_token.type = Token::Type::LBrace
        read_char
      when '}'
        @current_token.type = Token::Type::RBrace
        read_char
      when .ascii_number?
        consume_numeric
      when .ascii_whitespace?
        consume_whitespace
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
  end
end
