module ::Taro::Compiler::Ast
  # A parameter for a method definition.
  # must be suffixed with a type restriction
  #
  # name ':' type_path
  #
  # def foo(param1 : String, param2 : Int32)
  class Param < Node
    property! name : String?
    property! restriction : Node?

    def initialize(@name = nil, @restriction = nil)
    end

    def accept_children(visitor)
      restriction?.try(&.accept(visitor))
    end

    def_equals_and_hash name?, restriction?
  end
end
