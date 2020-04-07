require "../../spec_helper"

describe "Module" do
  it "should parse a module definition" do
    it_parses(%Q(module MyModule {}), ModuleDef.new("MyModule"))
  end
end
