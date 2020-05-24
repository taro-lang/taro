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
    property  body         : Node
    property! return_type  : Node?

    def initialize(@name, @params = [] of Param, @body=Nop.new, *, @return_type=nil)
    end

    def accept_children(visitor)
      params.each(&.accept(visitor))  
      body.accept(visitor)
    end

    def_equals_and_hash name, params, body
  end
end
