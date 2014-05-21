module DataRows
  class LineItemDataRow < DataRow
    before_save :create_or_update_document

    private
    def create_or_update_document
      document_id = mapping.document_id

      document = document_id.present? ? imported_class.find(document_id) : imported_class.new

      @data.each do |row|
        document.items << create_line_item(row)
      end

      document_mapping_elements.each(&mapping_element_assignment(document, @data.first))

      if document.save
        self.external_id = contact.id
      else
        self.source = @data.to_csv(column_separator: import.attachment.column_separator, quote_character: import.attachment.quote_character)
        self.log = document.errors.full_messages.to_sentence
      end
    end

    def create_line_item(row)
      line_item = imported_class::LineItem.new
      line_item_mapping_elements.each(&mapping_element_assignment(line_item, row))
      line_item
    end

    def mapping_element_assignment(object, row)
      Proc.new do |mapping_element|
        value = mapping_element.convert(row)
        object.send("#{mapping_element.target}=", value)
      end
    end

    def imported_class
      @imported_class ||= Sk.const_get(mapping.import_type.classify)
    end

    def line_item_mapping_elements
      @line_item_mapping_elements ||= mapping.mapping_elements.for_line_items
    end


    def document_mapping_elements
      @document_mapping_elements ||= mapping.mapping_elements.for_documents
    end

    def mapping
      @mapping ||= self.import.attachment.mapping
    end

  end
end
