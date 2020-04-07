require "./node"

module ::Taro::Compiler::Ast
  # A container for one or more expressions. The main block of a program will
  # be an Expressions node. Other examples include function bodies, module
  # bodies, etc.
  class Expressions < Node
    property children : Array(Node)

    def initialize
      @children = [] of Node
    end

    def initialize(*children)
      @children = children.map { |c| c.as(Node) }.to_a
    end

    def initialize(other : self)
      @children = other.children
    end

    def accept_children(visitor)
      children.each(&.accept(visitor))
    end

    def location
      @location || @children.first?.try &.location
    end

    def end_location
      @end_location || @children.last?.try &.end_location
    end

    def_equals_and_hash children
  end
end
