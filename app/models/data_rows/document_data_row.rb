module DataRows
  class DocumentDataRow < DataRow
    before_save :create_document

    private

    def create_document
      document  = imported_class.new
      line_item = Sk::Item.new
      line_item.type = 'LineItem'
      document_mapping_elements .each(&mapping_element_assignment(document, @data))
      line_item_mapping_elements.each(&mapping_element_assignment(line_item, @data))

      document.items = [line_item]

      # VERY IMPORTANT
      # line_items is deprecated, but still available
      # takes precedence over #items
      document.line_items = nil

      if document.save
        self.external_id = document.id
      else
        self.source = @data.to_csv(col_sep: import.attachment.column_separator, quote_char: import.attachment.quote_character)
        self.log    = document.errors.full_messages.to_sentence
      end
    end

    def document_mapping_elements
      @document_mapping_elements ||= mapping.mapping_elements.for_documents
    end

    def line_item_mapping_elements
      @line_item_mapping_elements ||= mapping.mapping_elements.for_line_items
    end
  end
end
