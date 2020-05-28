require "./return_type"

module ::Taro::Compiler::Ast
    
    class Unit < ReturnType
        def initialize(@name = "Unit"); end
    end
  end
  