FactoryGirl.define do
  factory :mapping do
    import_type   'document'
    document_type 'invoice'
    mapping_elements = []

    before(:create) do |mapping|
      mapping.mapping_elements << build(:mapping_element, mapping: mapping) unless mapping.mapping_elements.present?
    end
  end
end
