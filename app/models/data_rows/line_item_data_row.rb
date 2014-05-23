module DataRows
  class LineItemDataRow < DataRow
    before_save :create_or_update_document

    private
    def create_or_update_document
      # you can't do document.items << { new item }
      document.items = @data.map do |row|
        create_line_item(row)
      end

      # VERY IMPORTANT
      # line_items is deprecated, but still available
      # takes precedence over #items
      document.line_items = nil

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

    def line_item_mapping_elements
      @line_item_mapping_elements ||= mapping.mapping_elements.for_line_items
    end

    def mapping
      @mapping ||= self.import.attachment.mapping
    end

    def document
      @document ||= mapping.document_id.present? ? imported_class.find(mapping.document_id) : imported_class.new
    end

  end
end
