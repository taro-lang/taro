module ::Taro::Compiler::Ast
    # A module definition. The name of the module must be a IdentifierU (i.e., it
    # must start with a capital letter).
    #
    #   module Main { 
    #     body
    #   }
    class TypeRestriction < Node
      property name : String
  
      def initialize(@name)
      end
   
      def_equals_and_hash name
    end
  end