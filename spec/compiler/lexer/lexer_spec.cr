require "../../spec_helper"

include Taro::Compiler::Lexer

def perform_lex(source_file_path)
  Lexer.new.run([SourceFile.create(source_file_path)])
end

def assert_file(source_file_name)
  lexed_file = perform_lex("#{__DIR__}/source/#{source_file_name}.taro").first
  expected_file = "#{__DIR__}/expected/#{source_file_name}.txt"
  if !File.exists?(expected_file)
    puts "Generating missing expected file: #{expected_file}"
    File.open(expected_file, "w") { |f| f.print lexed_file.tokens.map(&.to_s).join("\n") }
  end
  expected_tokens = File.read(expected_file)
  actual = lexed_file.tokens.map(&.to_s).join("\n")
  puts actual
  actual.should eq(expected_tokens)
end

describe Lexer do
  # it "should correctly parse keywords" do
  #   assert_file("keyword_module")
  # end

  it "should correctly parse literals" do
    # assert_file("literal_string")
    # assert_file("literal_number")
    assert_file("literal_float")
  end

  # it "should correctly parse separators" do
  # end

  # it "should correctly parse identifiers" do
  # end

  # it "should correctly parse operators" do
  #   assert_file("operator_assign")
  # end
end
