require 'spec_helper'

describe DataRows::DocumentDataRow do

  it { should belong_to :import }

  let(:import) { build(:import) }
  let(:data_row) { described_class.new(import: import) }

  describe '#create_document' do
    pending
  end

  describe '#line_item_mapping_elements and #document_mapping_elements' do
    let(:mapping) { create(:mapping) }
    let!(:document_mapping_element) { create(:mapping_element, mapping: mapping) }
    let!(:line_item_mapping_element) { create(:line_item_mapping_element, mapping: mapping) }
    let(:attachment) { create(:attachment, mapping: mapping) }
    let(:import) { build(:import, attachment: attachment) }

    context 'for document' do
      it "should create the correct data rows" do
        document_mapping_element2 = [FactoryGirl.create(:mapping_element)]
        mapping2 = FactoryGirl.create(:mapping, mapping_elements: document_mapping_element2)
        attachment2 = FactoryGirl.create(:attachment, mapping: mapping2)
        import2 = FactoryGirl.build(:import, attachment: attachment2)

        import2.attachment.mapping.should eq mapping2
        
        data_row2 = described_class.new(import: import2)
        
        dr_mapping_elements = data_row2.send(:document_mapping_elements).to_a
        dr_mapping_elements.should eq document_mapping_element2
      end
      

      # subject { data_row2.send(:document_mapping_elements).to_a }
      # it { should eq [document_mapping_element2] }
    end

    context 'for line item' do
      subject { data_row.send(:line_item_mapping_elements) }
      it { should eq [line_item_mapping_element] }
    end
  end

  describe '#mapping' do

  end
end
