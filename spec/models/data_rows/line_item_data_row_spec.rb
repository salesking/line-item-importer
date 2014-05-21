require 'spec_helper'

describe DataRows::LineItemDataRow do

  it { should belong_to :import }

  let(:import) { build(:import) }
  let(:data_row) { described_class.new(import: import) }

  let(:pfudor) { %w(pink fluffy unicorns dancing on rainbows) }

  describe '#create_or_update_document' do
    pending
  end

  describe '#create_line_item' do
    let(:data_row) { described_class.new }
    before do
      data_row.stub(imported_class: Sk::Invoice, line_item_mapping_elements: [create(:line_item_mapping_element), create(:join_line_item_mapping_element)])
    end

    it 'creates a line item' do
      line_item = data_row.send(:create_line_item, pfudor)
      line_item.name.should eq 'fluffy'
      line_item.description.should eq 'unicorns dancing'
    end
  end

  describe '#mapping_element_assignment' do
    let(:object_to_assign) { nil }
    subject { data_row.send(:mapping_element_assignment, object_to_assign, pfudor) }

    it {should be_a Proc}

    context 'when proc called' do
      let(:objects_to_traverse) { [
        double(convert: 'PINK',     target: 'color'),
        double(convert: 'RAINBOWS', target: 'dancing_location'),
        double(convert: 'SMILE',    target: 'magical_fur_texture')
      ] }
      let(:object_to_assign) { double(:color= => 'PINK', :dancing_location= => 'RAINBOWS', :magical_fur_texture= => 'SMILE') }

      it 'passes mocks' do
        objects_to_traverse.each(&subject)
      end
    end
  end

  describe '#imported_class' do
    let(:attachment) { create(:attachment, mapping: mapping) }
    let(:import) { build(:import, attachment: attachment) }
    %w(invoice order estimate credit_note).each do |valid_class|
      context "when importing to #{valid_class}" do
        let(:mapping) { create(:mapping, import_type: valid_class) }

        subject { data_row.send(:imported_class) }
        it { should be Sk.const_get(valid_class.classify) }
      end
    end
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
    subject { data_row.send(:mapping) }

    it { should eq import.attachment.mapping }
  end
end
