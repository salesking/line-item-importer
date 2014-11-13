module DataRows
  class LineItemDataRow < DataRow
    before_save :create_or_update_document

    private
    def create_or_update_document
      item_count = 0
      
      if document.try(:items) && document.items.is_a?(Array)
        item_count = document.items.length
      else
        document.items = []
      end
      
      # you can't do document.items << { new item }
      @data.each do |row|
        document.items << create_line_item(row, item_count+=1)
      end

      # VERY IMPORTANT
      # line_items is deprecated, but still available
      # takes precedence over #items
      document.attributes.delete(:line_items)

      if document.save
        self.external_id = document.id
      else
        self.source = @data.to_csv(col_sep: import.attachment.column_separator, quote_char: import.attachment.quote_character)
        self.log = document.errors.full_messages.to_sentence
      end
    end

    def create_line_item(row, position)
      line_item = Sk::Item.new
      line_item.type = 'LineItem'
      line_item.position = position
      line_item_mapping_elements.each(&mapping_element_assignment(line_item, row))
      # default price single to 1 so import does not fail
      line_item.price_single = 1 unless line_item.respond_to?(:price_single)
      line_item
    end

    def line_item_mapping_elements
      @line_item_mapping_elements ||= mapping.mapping_elements.for_line_items
    end

    def document
      @document ||= mapping.document_id.present? && imported_class.find(mapping.document_id).presence || imported_class.new
    end
  end
end
