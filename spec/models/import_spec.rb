require 'spec_helper'

describe Import do

  it { should have_many(:data_rows).dependent(:destroy) }
  it { should belong_to(:attachment) }

  it { should validate_presence_of(:attachment) }

  describe 'data import', vcr: true do
    let(:mapping)          { create(:mapping) }
    let!(:mapping_element1) { create(:line_item_mapping_element, mapping: mapping, source: 3, target: 'name') }
    let!(:mapping_element2) { create(:price_line_item_mapping_element, mapping: mapping, source: 9) }
    let!(:mapping_element3) { create(:line_item_mapping_element, mapping: mapping, source: 10, target: 'quantity') }
    let(:attachment)       { create(:attachment, mapping: mapping) }
    let(:import)           { build(:import, attachment: attachment) }

    it 'creates data_rows and succeeds' do
      expect(lambda { import.save }).to change(DataRow, :count).by(1)
      expect(import).to be_success
    end

    context 'when mapping element does not match price_single' do
      let!(:mapping_element2) { create(:line_item_mapping_element, mapping: mapping, source: 9, target: 'external_ref') }

      it 'creates failed data_rows' do
        expect(lambda { import.save }).to change(DataRow, :count).by(1)
        expect(import).not_to be_success
        data_row = import.data_rows.first
        expect(data_row.external_id).to be_nil
        expect(data_row.log).to eq ['items.price_single', 'is not a number'].inspect
      end
    end
  end
end
