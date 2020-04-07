module Taro::Compiler::Parsers
  # A code block is a set of expressions contained by some other expression.
  # For example, the body of a method definition.
  def parse_code_block(*terminators)
    block = nil
    skip_space_and_newlines
    until terminators.includes?(current_token.type)
      block ||= Expressions.new
      block.children << parse_expression
      skip_space
      # In a code block, the last expression does not require a delimiter.
      # For example, `call{ a = 1; a + 2 } is valid, even though `a + 2` is
      # not followed by a delimiter. So, if the next significant token is a
      # terminator, stop expecting expressions/delimiters.
      break if terminators.includes?(current_token.type)
      # Additionally, doc comments are not (can not be) delimited by newlines
      # since they do not have an explicit closing token, so skip that
      # expectation if the previous expression was a doc comment.
      # unless block.children.last.is_a?(DocComment)
        expect_delimiter_or_eof
      # end
      skip_space_and_newlines
    end

    # If there were no expressions in the block, return a Nop instead.
    block || Nop.new
  end
end
