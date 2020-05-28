require "../../spec_helper"

describe "Def" do
  it "should parse simple function def" do
    it_parses(%Q(def main() : Unit {}), FuncDef.new("main"))
  end

  it "should parse with parameters" do 
    it_parses(
      %Q(def main(param1 : String, param2 : Bool) : Unit {}), 
      FuncDef.new("main", [p("param1", rt("String")), p("param2", rt("Bool"))])
    )
  end

  it "should parse a function defintion across multiple lines" do
    source = <<-CODE
    def main() : Unit {

    }
    CODE
    it_parses(source, FuncDef.new("main"))
  end

  it "should parse a function defintion across multiple lines with left curly on a newline" do
    source = <<-CODE
    def main() : Unit
    {
      
    }
    CODE
    it_parses(source, FuncDef.new("main"))
  end

  it "should allow nested functions" do
    source = <<-CODE
    def foo() : String {
      def bar() : String {  
      }
    }
    CODE
    nested = FuncDef.new("bar", [] of Param, rt("String")) 
    it_parses(source, FuncDef.new("foo", [] of Param, rt("String"), e(nested)))
  end

  it "should not have a capitalised name" do
    it_does_not_parse(%Q(def MyFunc : Unit {}))
  end
end
