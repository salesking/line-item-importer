require 'spec_helper'
describe MappingElement do

  describe 'in general' do

    it "should validate convert type" do
      obj = MappingElement.new :conv_type => 'what', :source=>'0'
      obj.should_not be_valid
      obj.errors[:conv_type].should_not be_empty
    end
  end

  describe 'convert' do

    it "should return field value" do
      obj = MappingElement.new :source=>'0'
      obj.convert(['Pipi']).should == 'Pipi'
    end

    it "should convert enum" do
      obj = MappingElement.new :conv_opts => '{"male":"Herr","female":"Frau"}', :conv_type=>'enum', :source=>'0'
      obj.convert(['Frau']).should == 'female'
    end

    it "should convert date" do
      obj = MappingElement.new :conv_opts => '{"date":"%d.%m.%Y"}', :conv_type=>'date', :source=>'0'
      obj.convert(['1.6.1976']).should == "1976.06.01"
    end

    it "should convert date without time" do
      obj = MappingElement.new :conv_opts => '{"date":"%d.%m.%Y"}', :conv_type=>'date', :source=>'0'
      obj.convert(['1.6.1976 00:00:00']).should == "1976.06.01"
    end

    it "should convert date and rescue with incoming string" do
      source = ['1/6/1976 00:00:00']
      obj = MappingElement.new :conv_opts => '{"date":"%d.%m.%Y"}', :conv_type=>'date', :source=>'0'
      obj.convert(source).should == source[0]
    end

    it "should convert joined fields" do
      source = ['tag1', 'tag2', 'tag3','other']
      obj = MappingElement.new :conv_type=>'join', :source=>'0,1,2'
      obj.convert(source).should == source[0..2].join(' ')
    end
  end
end