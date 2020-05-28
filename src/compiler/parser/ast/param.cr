module ::Taro::Compiler::Ast
  # A parameter for a method definition.
  # must be suffixed with a type restriction
  #
  # name ':' type_path
  #
  # def foo(param1 : String, param2 : Int32)
  class Param < Node
    property name : String
    property return_type : ReturnType

    def initialize(@name, @return_type)
    end

    def accept_children(visitor)
      return_type.accept(visitor)
    end

    def_equals_and_hash name, return_type
  end
end
