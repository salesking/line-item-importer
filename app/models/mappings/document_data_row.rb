module Mappings
  class DocumentDataRow < DataRow
    before_save :create_document

    private

    def create_document
      document = Sk::Invoice.new
    end
  end
end
