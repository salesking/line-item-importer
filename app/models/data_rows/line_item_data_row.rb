module DataRows
  class LineItemDataRow < DataRow
    belongs_to :document_data_row
  end
end