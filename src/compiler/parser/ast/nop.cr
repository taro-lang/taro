module ::Taro::Compiler::Ast
  # A No-op. Used as a placeholder for empty bodies, such as an empty method
  # definition or empty class body.
  class Nop < Node
    def_equals_and_hash
  end
end
