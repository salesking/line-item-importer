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
      subject { data_row.send(:document_mapping_elements) }
      it { should eq [document_mapping_element] }
    end

    context 'for line item' do
      subject { data_row.send(:line_item_mapping_elements) }
      it { should eq [line_item_mapping_element] }
    end
  end

  describe '#mapping' do

  end
end
