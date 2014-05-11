require 'spec_helper'

describe Import do
  it { should have_many(:data_rows).dependent(:destroy) }
  it { should belong_to(:attachment) }

  it { should validate_presence_of(:attachment) }

  describe "data import" do
    before :each do
      @mapping = create(:mapping)
      create(:mapping_element, mapping: @mapping, source: 8, target: 'address.address1')
      create(:mapping_element, mapping: @mapping, source: 9, target: 'address.zip')
      create(:mapping_element, mapping: @mapping, source: 10, target: 'address.city')
      @attachment = create(:attachment, mapping: @mapping)
      @import = build(:import, attachment: @attachment)
      @contact = stub_sk_contact
    end

    it "should create data_rows" do
      @contact.should_receive(:save).and_return(true)
      lambda { @import.save }.should change(DataRow, :count).by(1)
    end

    it "should create an address" do
      @contact.should_receive(:save).and_return(true)
      @import.save
      @contact.addresses[0].zip.should == '83620'
      @contact.addresses[0].address1.should == 'Hubertstr. 205'
      @contact.addresses[0].city.should == 'Feldkirchen'
    end

    it "should create failed data_rows" do
      @contact.should_receive(:save).and_return(false)
      @contact.errors.should_receive(:full_messages).and_return(['some error message'])
      lambda { @import.save }.should change(DataRow, :count).by(1)
      data_row = @import.data_rows.first
      data_row.sk_id.should be_nil
      data_row.log.should == 'some error message'
    end

    it "should be success if no rows failed" do
      @contact.should_receive(:save).and_return(true)
      @contact.should_receive(:id).and_return("some_uuid")
      @import.save
      @import.should be_success
    end
  end
end
