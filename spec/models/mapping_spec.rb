require 'spec_helper'

describe Mapping do
  it { should have_many(:mapping_elements).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:nullify)      }

  let(:mapping)   { create(:mapping, :company_id => 'a company')       }
  let!(:mapping2) { create(:mapping, :company_id => 'another company') }

  before :each do
    create(:mapping_element,          mapping: mapping)
    create(:gender_mapping_element,   mapping: mapping)
    create(:birthday_mapping_element, mapping: mapping)
  end

  context :scopes do
    describe '.by_company' do
      subject { Mapping.by_company('a company') }
      it { should include(mapping) }
      it { should_not include(mapping2) }
    end

    describe '.with_fields' do
      subject { Mapping.with_fields }
      it { should include(mapping) }
      it { should_not include(mapping2) }
    end
  end

  describe '#title' do
    subject { mapping.title }
    it { should eq '3 fields: number, gender, and birthday' }
  end
end
