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
        float_literals = parse_float_literals(line, line_number)
        number_literals = parse_number_literals(line, line_number, float_literals.excludes)
        keywords = parse_keywords(line, line_number, number_literals.excludes)
        identifiers = parse_identifiers(line, line_number, keywords.excludes)
        whitespace = parse_whitespace(line, line_number, identifiers.excludes)
        separators = parse_separators(line, line_number, whitespace.excludes)
        operators = parse_operators(line, line_number, separators.excludes)
        unknown = parse_unknown(line, line_number, operators.excludes)
        
        tokens += float_literals.tokens
        tokens += number_literals.tokens
        tokens += keywords.tokens
        tokens += identifiers.tokens
        tokens += whitespace.tokens
        tokens += separators.tokens
        tokens += operators.tokens
        tokens += unknown.tokens

        tokens.sort! { |a, b| [a.line_number, a.start_position] <=> [b.line_number, b.start_position] }

        line_number += 1
      end

      LexedFile.new(source_file.file_path, source_file.file_content, tokens)
    end


    private def parse_float_literals(line, line_number, excludes = [] of Int32) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { c.number? }).each do |group|
        word = group.map(&.value).join("")
        indices = group.map(&.index)
        tokens << Token.new(TokenType.new("Number", word), line_number, group.size, indices.min, indices.max)
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_number_literals(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { c.number? }).each do |group|
        word = group.map(&.value).join("")
        indices = group.map(&.index)
        tokens << Token.new(TokenType.new("Number", word), line_number, group.size, indices.min, indices.max)
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_keywords(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { c.alphanumeric? }).each do |group|
        word = group.map(&.value).join("")

        if Groups.is_keyword?(word)
          indices = group.map(&.index)
          tokens << Token.new(Groups.keywords[word], line_number, group.size, indices.min, indices.max)
        end
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_whitespace(line, line_number, excludes) : LexingResult
      tokens = _parse_internal(line, excludes, ->(c : Char) { c.whitespace? }).map do |group|
        indices = group.map(&.index)
        Token.new(Whitespace, line_number, group.size, indices.min, indices.max)
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_identifiers(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { c.alphanumeric? }).each do |group|
        word = group.map(&.value).join("")
        indices = group.map(&.index)
        tokens << Token.new(TokenType.new("Identifier", word), line_number, group.size, indices.min, indices.max)
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_separators(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { !c.alphanumeric? }).each do |group|
        word = group.map(&.value).join("")
        indices = group.map(&.index)
        if Groups.is_separator?(word)
          tokens << Token.new(Groups.separators[word], line_number, group.size, indices.min, indices.max)
        end
      end

      LexingResult.new(tokens, exclusions(tokens, excludes))
    end

    private def parse_operators(line, line_number, excludes) : LexingResult
      tokens = [] of Token
      _parse_internal(line, excludes, ->(c : Char) { !c.alphanumeric? }).each do |group|
        word = group.map(&.value).join("")
        indices = group.map(&.index)
        if Groups.is_operator?(word)
          tokens << Token.new(Groups.operators[word], line_number, group.size, indices.min, indices.max)
        end
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

    private def _parse_internal(line, excludes, condition) : Array(Array(LexingContext))
      group = [] of LexingContext
      groups = [] of Array(LexingContext)
      line.chars.each_with_index do |c, i|
        next if excludes.includes?(i)

        if condition.call(c)
          if group.empty?
            group << LexingContext.new(i, c)
          else
            if i == group.last.index + 1
              group << LexingContext.new(i, c)
            else
              groups << group
              group = [] of LexingContext
              group << LexingContext.new(i, c)
            end
          end
        else
          groups << group unless group.empty?
          group = [] of LexingContext
        end
      end

      groups << group unless group.empty?
      groups
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
