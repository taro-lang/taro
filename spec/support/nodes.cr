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
