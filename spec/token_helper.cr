module TokenHelper
  STATIC_TOKENS = {

    # Literals
    Token::Type::Integer    => "1",
    Token::Type::Float      => "1.1",
    Token::Type::String     => "\"hello\"",
    Token::Type::Char       => "'c'",
    Token::Type::True       => "true",
    Token::Type::False      => "false",
    Token::Type::Identifier => "identifier",

    # Keywords
    Token::Type::Module => "module",
    Token::Type::Def    => "def",
    Token::Type::Val    => "val",
    Token::Type::Var    => "var",
    Token::Type::If     => "if",
    Token::Type::Else   => "else",
    Token::Type::Record => "record",
    Token::Type::Public => "public",
    Token::Type::Const  => "const",
    Token::Type::Ref    => "ref",
    Token::Type::Enum   => "enum",

    # Operators
    Token::Type::Plus         => "+",
    Token::Type::Minus        => "-",
    Token::Type::Asterisk     => "*",
    Token::Type::Pow          => "**",
    Token::Type::Slash        => "/",
    Token::Type::Modulo       => "%",
    Token::Type::Assign       => "=",
    Token::Type::Not          => "!",
    Token::Type::Less         => "<",
    Token::Type::LessEqual    => "<=",
    Token::Type::Greater      => ">",
    Token::Type::GreaterEqual => ">=",
    Token::Type::NotEqual     => "!=",
    Token::Type::Equal        => "==",
    Token::Type::AndAnd       => "&&",
    Token::Type::OrOr         => "||",
    Token::Type::Ampersand    => "&",
    Token::Type::Pipe         => "|",
    Token::Type::LArrow       => "<-",
    Token::Type::RArrow       => "->",

    # Separators
    Token::Type::LParen  => "(",
    Token::Type::RParen  => ")",
    Token::Type::LCurly  => "{",
    Token::Type::RCurly  => "}",
    Token::Type::LSquare => "[",
    Token::Type::RSquare => "]",
    Token::Type::Comma   => ",",
    Token::Type::Point   => ".",
    Token::Type::Colon   => ":",
    Token::Type::Semi    => ";",

    # Misc
    Token::Type::Comment    => "--",
    Token::Type::NewLine    => "\n",
    Token::Type::Whitespace => " ",
    Token::Type::Eof        => "\0",

  }
end
