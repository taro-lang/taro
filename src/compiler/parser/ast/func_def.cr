module ::Taro::Compiler::Ast
  # A function definition. Parameters are supplied in parentheses. 
  # If the function does not accept parameters then parentheses can be omitted
  # Must start with a lowercase letter
  # Must have a return type
  #
  #   def main(param1 : String, param2 : Int32) : Unit {
  #     body
  #   }
  #
  class FuncDef < Node
    property  name         : String
    property  params       : Array(Param)
    property  return_type  : ReturnType
    property  body         : Node

    def initialize(@name, @params = [] of Param, @return_type=Unit.new, @body=Nop.new)
    end

    def accept_children(visitor)
      params.each(&.accept(visitor))  
      return_type.accept(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash name, params, return_type, body
  end
end
