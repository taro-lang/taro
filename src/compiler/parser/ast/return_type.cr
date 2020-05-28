require "./node"

module ::Taro::Compiler::Ast
    # A return type definition.
    #  : String 
    class ReturnType < Node
      property name : String
  
      def initialize(@name)
      end
   
      def_equals_and_hash name
    end
  end