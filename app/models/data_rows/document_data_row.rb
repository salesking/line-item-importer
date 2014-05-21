module DataRows
  class DocumentDataRow < DataRow
    before_save :create_document

    private

    def create_document
      document_id = mapping.document_id

      document = document_id.present? ? imported_class.find(document_id) : imported_class.new

      @data.each do |row|
        document.items << create_line_item(row)
      end

      if document.save
        self.external_id = contact.id
      else
        self.source = @data.to_csv(column_separator: import.attachment.column_separator, quote_character: import.attachment.quote_character)
        self.log = document.errors.full_messages.to_sentence
      end
    end

    def create_line_item(row)
      line_item = imported_class::LineItem.new
      line_item_mapping_elements.each do |mapping_element|
        value = mapping_element.convert(row)
        line_item.send("#{mapping_element.target}=", value)
      end
      line_item
    end

    def imported_class
      @imported_class ||= Sk.const_get(mapping.import_type.classify)
    end

    def line_item_mapping_elements
      @line_item_mapping_elements ||= mapping.mapping_elements.for_line_items
    end

    def mapping
      @mapping ||= self.import.attachment.mapping
    end
  end
end
