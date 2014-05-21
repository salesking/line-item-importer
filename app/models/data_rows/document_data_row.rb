module DataRows
  class DocumentDataRow < DataRow
    before_save :create_document

    private
  end
end
