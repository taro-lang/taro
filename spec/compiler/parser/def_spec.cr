require "../../spec_helper"

describe "Def" do
  it "should parse simple def" do
    it_parses(%Q(def main() : Unit {}), FuncDef.new("main"))
  end

  # it "should parse a module defintion across multiple lines" do
  #   source = <<-CODE
  #   module MyModule {

  #   }
  #   CODE
  #   it_parses(source, ModuleDef.new("MyModule"))
  # end

  # it "should parse a module defintion across multiple lines with left curly on a newline" do
  #   source = <<-CODE
  #   module MyModule
  #   {
      
  #   }
  #   CODE
  #   it_parses(source, ModuleDef.new("MyModule"))
  # end

  # it "should allow nested modules" do
  #   source = <<-CODE
  #   module MyModule {
  #     module MyModule2 {  
  #     }
  #   }
  #   CODE
  #   it_parses(source, ModuleDef.new("MyModule", e(ModuleDef.new("MyModule2"))))
  # end

  # it "should have a capitalised name" do
  #   it_does_not_parse(%Q(module mymodule {}))
  # end
end
