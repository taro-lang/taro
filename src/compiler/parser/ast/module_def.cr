module ::Taro::Compiler::Ast
  # A module definition. The name of the module must be a IdentifierU (i.e., it
  # must start with a capital letter).
  #
  #   module Main { 
  #     body
  #   }
  class ModuleDef < Node
    property name : String
    property body : Node

    def initialize(@name, @body = Nop.new)
    end

    def accept_children(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash name, body
  end
end
