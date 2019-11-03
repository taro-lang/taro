module ::Taro::Compiler::Lexer::TokenTypes
  struct TokenType
    getter name : String
    getter value : String

    def initialize(@name : String, @value : String); end
  end

  Whitespace = TokenType.new("Space", " ")

  # Keywords
  Module = TokenType.new("Module", "module")
  Def    = TokenType.new("Def", "def")
  Var    = TokenType.new("Var", "var")
  Val    = TokenType.new("Val", "val")

  # Separators
  LBrace   = TokenType.new("LBrace", "{")
  RBrace   = TokenType.new("RBrace", "}")
  LParen   = TokenType.new("LParen", "(")
  RParen   = TokenType.new("RParen", ")")
  LBracket = TokenType.new("LBracket", "[")
  RBracket = TokenType.new("RBracket", "]")
  Colon    = TokenType.new("Colon", ":")

  # Operators
  Assign             = TokenType.new("Assign", "=")
  Plus               = TokenType.new("Plus", "+")
  Minus              = TokenType.new("Minus", "-")
  Asterisk           = TokenType.new("Asterisk", "*")
  Pow                = TokenType.new("Pow", "**")
  Slash              = TokenType.new("Slash", "/")
  Dot                = TokenType.new("Dot", ".")
  And                = TokenType.new("And", "&&")
  Or                 = TokenType.new("Or", "||")
  Modulo             = TokenType.new("Modulo", "%")
  LessThan           = TokenType.new("LessThan", "<")
  GreaterThan        = TokenType.new("GreaterThan", ">")
  Equal              = TokenType.new("Equal", "==")
  NotEqual           = TokenType.new("NotEqual", "!=")
  LessThanOrEqual    = TokenType.new("LessThanOrEqual", "<=")
  GreaterThanOrEqual = TokenType.new("GreaterThanOrEqual", ">=")
  Compares           = TokenType.new("Compares", "<=>")

  class Groups
    def self.keywords
      {
        "def"    => Def,
        "module" => Module,
        "var"    => Var,
        "val"    => Val,
      }
    end

    def self.is_keyword?(value : String) : Bool
      keywords.keys.includes?(value)
    end

    def self.separators
      {
        "{" => LBrace,
        "}" => RBrace,
        "(" => LParen,
        ")" => RParen,
        "[" => LBracket,
        "]" => RBracket,
        ":" => Colon,
      }
    end

    def self.is_separator?(value : String) : Bool
      separators.keys.includes?(value)
    end

    def self.operators
      {
        "<=>" => Compares,
        "=="  => Equal,
        "!="  => NotEqual,
        "<="  => LessThanOrEqual,
        ">="  => GreaterThanOrEqual,
        "&&"  => And,
        "||"  => Or,
        "**"  => Pow,
        "*"   => Asterisk,
        "/"   => Slash,
        "."   => Dot,
        "%"   => Modulo,
        "<"   => LessThan,
        ">"   => GreaterThan,
        "="   => Assign,
        "+"   => Plus,
        "-"   => Minus,
        
      }
    end

    def self.is_operator?(value : String) : Bool
      operators.keys.includes?(value)
    end
  end
end
