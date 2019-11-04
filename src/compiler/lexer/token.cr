require "./location"

module Taro::Compiler
  class Token

    enum Type
      Integer             # [0-9]+
      Float               # [0-9][_0-9]*\.[0-9]+
      String              # "string"
      Char                # 'char'

      Identifier          # [a-z][_a-zA-Z0-9]* 
      Module              # module
      Def                 # def

      True                # true
      False               # false

      Plus                # +
      Minus               # -
      Asterisk            # *
      Pow                 # **
      Slash               # /
      Modulo              # %

      Assign              # =
      Not                 # !
      Less                # <
      LessEqual           # <=
      Greater             # >
      GreaterEqual        # >=
      NotEqual            # !=
      Equal               # ==
      AndAnd              # &&
      OrOr                # ||

      Ampersand           # &
      Pipe                # |

      LParen              # (
      RParen              # )
      LBrace              # {
      RBrace              # }
      LBracket            # [
      RBracket            # ]

      Comma               # ,
      Point               # .
      Colon               # :
      Semi                # ;

      Comment             # --
      NewLine             # \n
      Whitespace          # space, tab, etc.
      Eof                 # End of file
      Unknown             # Unknown type
  
    def self.whitespace
      [ Whitespace, Unknown, Comment ]
    end

    def whitespace?
      self.class.whitespace.includes?(self)    
    end

    def self.keywords
      [ Module, Def ]    
    end

    def self.keyword_map
      {
        "module" => Module,
        "def"    => Def,
      }
    end

    def self.keyword?
      self.class.keywords.includes?(self)    
    end

    def self.delimiters
      [ NewLine, Semi, Eof ]
    end

    def delimiter?
       self.class.delimiters.includes?(self)
    end

    def self.unary_operators
      [ Plus, Minus, Not, Asterisk, Ampersand ]
    end

    def self.binary_operators
      [ Plus, Minus, Asterisk, Slash, Modulo, Assign, Less, LessEqual,
      GreaterEqual, Greater, NotEqual, Equal, AndAnd, OrOr]
    end

    def unary_operator?
      self.class.unary_operators.includes?(self)
    end

    def binary_operator?
      self.class.binary_operators.includes?(self)
    end

    def operator?
      unary_operator? || binary_operator?
    end
  end

    property type : Token::Type
    property value : String
    property raw : String
    property location : Location

    def initialize(@type = Type::Unknown, @value = "", @raw = "", @location = Location.new)
    end

    def to_s(io)
      io << "#{@location.to_s.ljust(9, ' ')}"
      io << " │ "

      io << "#{@type.to_s.ljust(12, ' ')}"
      io << "│ "
      io << "#{@raw.strip}"
    end

    def inspect(io)
      io << "#{@type}:#{@raw.strip}"
    end
  end
end
