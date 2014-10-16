require 'spec_helper'

describe Attachment do
  it { should belong_to(:mapping) }
  it { should have_many(:imports).dependent(:destroy) }

  ['filename', 'quote_character', 'encoding', 'disk_filename'].each do |attribute|
    it { should validate_presence_of(attribute)}
  end

  describe 'validations' do
    context 'column_separator' do
      let(:attachment) { build(:attachment, column_separator: separator) }
      before           { attachment.valid? }
      subject          { attachment }
      context 'when present' do
        let(:separator) { ',' }
        its(:errors) { should_not include :column_separator }
      end

      context 'when blank' do
        let(:separator) { '' }
        its(:errors) { should include :column_separator }
      end

      # "\t" is blank, yet tabulator is often used in CSV files
      context 'when blank, but \t' do
        let(:separator) { "\\t" }
        its(:errors) { should_not include :column_separator }
      end
    end
  end

  let(:attachment) { create(:attachment) }

  it 'should set filename and disk_filename' do
    attachment.filename.should == 'test1.csv'
    attachment.disk_filename.should_not be_empty
  end

  it 'should remove file on destroy' do
    file_path = attachment.full_filename
    attachment.destroy
    File.exist?(file_path).should eq false
  end

  it 'should silently ignore missing files on destroy' do
    file_path = attachment.full_filename
    File.delete(file_path)
    lambda {attachment.destroy}.should_not raise_error #(Errno::ENOENT)
  end

  it 'parses csv data' do
    attachment.rows.size.should == 2
    attachment.rows.first.size.should be > 1
  end

  it 'reveals specified number of rows' do
    attachment.rows(1).size.should == 1
  end

end
