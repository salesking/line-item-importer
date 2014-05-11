require 'spec_helper'
describe Sk do
  it "should read schema" do
    hsh = Sk.read_schema('contact')
    hsh['title'].should == 'contact'
  end
end
