module ::Taro::Compiler::Ast
  abstract class Node
    property location : Location?
    property end_location : Location?

    def at(@location : Location)
      self
    end

    def at_end(@end_location : Location)
      self
    end

    def at(node : Node)
      @location = node.location
      @end_location = node.end_location
      self
    end

    def at_end(node : Node)
      @end_location = node.end_location
      self
    end

    def at(node : Nil)
      self
    end

    def at_end(node : Nil)
      self
    end

    def accept(visitor)
      visitor.visit(self)
    end

    def accept_children(visitor)
    end

    def class_desc : String
      {{@type.name.split("::").last.id.stringify}}
    end
  end
end
