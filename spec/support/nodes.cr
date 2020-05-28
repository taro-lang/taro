require "../spec_helper.cr"

# e(*nodes)
#
# Generate an Expressions node from the given nodes.
def e(*nodes : Node)
  Expressions.new(*nodes)
end

def e
  Expressions.new
end

# p(name, return_type)
#
# Generate a Param node.
def p(name, return_type = Unit.new)
  Param.new(name, return_type)
end

# rt("String")
# Generate a ReturnType node
def rt(name)
  ReturnType.new(name)
end
