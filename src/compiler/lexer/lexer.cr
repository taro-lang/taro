require "string_scanner"
require "./tokens"

module ::Taro::Compiler::Lexer
  struct SourceFile
    getter file_path : String
    getter file_content : String

    def initialize(@file_path, @file_content); end

    def self.create(file_path : String)
      begin
        content = File.read(file_path)
        SourceFile.new(file_path, content)
      rescue e
        raise "Error: could not read file: #{file_path} due to: #{e.message}"
      end
    end
  end

  struct LexedFile
    getter file_path : String
    getter raw_content : String
    getter tokens : Array(Token)

    def initialize(@file_path, @raw_content, @tokens); end
  end

  struct Token
    getter type : TokenType
    getter line_number : Int32
    getter length : Int32
    getter start_position : Int32
    getter end_position : Int32

    def initialize(@type : TokenType, @line_number : Int32, @length : Int32, @start_position : Int32, @end_position : Int32); end

    def to_s
      "#{@type.name} (#{@type.value}) line: #{@line_number}, length: #{@length}, position: (#{@start_position},#{@end_position})"
    end
  end

  struct LexingResult
    getter tokens : Array(Token)
    getter excludes : Array(Int32)

    def initialize(@tokens : Array(Token), @excludes : Array(Int32)); end
  end

  struct LexingContext
    getter index : Int32
    getter value : Char

    def initialize(@index : Int32, @value : Char); end
  end

  class Lexer
    def run(source_codes : Array(SourceFile)) : Array(LexedFile)
      source_codes.map do |source_file|
        parse(source_file)
      end
    end

    private def parse(source_file : SourceFile) : LexedFile
      tokens = [] of Token

      line_number = 0
      source_file.file_content.each_line do |line|
        chars = line.chars
        scanner = StringScanner.new(line)

        whitespace = parse_whitespace(scanner, chars, line_number)
        float_literals = parse_float_literals(scanner, chars, line_number, whitespace.excludes)
        number_literals = parse_number_literals(scanner, chars, line_number, float_literals.excludes)
        keywords = parse_keywords(scanner, chars, line_number, number_literals.excludes)
        separators = parse_separators(scanner, chars, line_number, keywords.excludes)
        operators = parse_operators(scanner, chars, line_number, separators.excludes)
        identifiers = parse_identifiers(scanner, chars, line_number, operators.excludes)
        unknown = parse_unknown(line, line_number, identifiers.excludes)

        tokens += keywords.tokens
        tokens += whitespace.tokens
        tokens += float_literals.tokens
        tokens += number_literals.tokens
        tokens += separators.tokens
        tokens += operators.tokens
        tokens += identifiers.tokens
        tokens += unknown.tokens

        tokens.sort! { |a, b| [a.line_number, a.start_position] <=> [b.line_number, b.start_position] }

        line_number += 1
      end
      LexedFile.new(source_file.file_path, source_file.file_content, tokens)
    end

    private def parse_keywords(scanner, chars, line_number, excludes = [] of Int32)
      scanner.reset
      tokens = [] of Token
      offset = 0
      while offset <= chars.size
        word = scanner.check(/[_[:alpha:]][_[:alnum:]]*/) || ""

        if Groups.is_keyword?(word)
          tokens << Token.new(Groups.keywords[word], line_number, word.size, offset, offset + (word.size - 1))
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_identifiers(scanner, chars, line_number, excludes)
      scanner.reset
      tokens = [] of Token
      offset = 0
      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.scan(/[_a-zA-Z][_a-zA-Z0-9]*/)
          if word
            tokens << Token.new(TokenType.new("Identifier", word), line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_float_literals(scanner, chars, line_number, excludes)
      scanner.reset
      tokens = [] of Token
      offset = 0
      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.scan(/[+-]?([0-9]+[.])[0-9]+/)
          if word
            tokens << Token.new(TokenType.new("Float", word), line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_number_literals(scanner, chars, line_number, excludes)
      scanner.reset
      tokens = [] of Token
      offset = 0
      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.scan(/[+-]?[0-9]+/)
          if word
            tokens << Token.new(TokenType.new("Number", word), line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_whitespace(scanner, chars, line_number, excludes = [] of Int32)
      scanner.reset
      tokens = [] of Token
      offset = 0
      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.scan(/\s+/)

          if word
            tokens << Token.new(Whitespace, line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_separators(scanner, chars, line_number, excludes)
      scanner.reset
      tokens = [] of Token
      offset = 0

      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.check(/(\{|\}|\(|\)|\[|\]|:)/) || ""
          if Groups.is_separator?(word)
            tokens << Token.new(Groups.separators[word], line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_operators(scanner, chars, line_number, excludes)
      scanner.reset
      tokens = [] of Token
      offset = 0

      while offset <= chars.size
        if !excludes.includes?(offset)
          word = scanner.scan(/(<=>|==|!=|<=|>=|&&|\|\||\*\*|\*|\/|\.|%|<|>|=|\+|-)/) || ""

          if Groups.is_operator?(word)
            tokens << Token.new(Groups.operators[word], line_number, word.size, offset, offset + (word.size - 1))
          end
        end

        offset = scanner.offset + 1
        scanner.offset = offset
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_unknown(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      line.chars.each_with_index do |c, i|
        next if excludes.includes?(i)
        tokens << Token.new(TokenType.new("Unknown", c.to_s), line_number, 1, i, i)
      end
      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def token_to_positions(token : Token) : Array(Int32)
      (token.start_position..token.end_position).to_a
    end

    private def exclusions(tokens, excludes)
      (tokens.flat_map { |t| token_to_positions(t) } + excludes).sort
    end
  end

  include TokenTypes
end
