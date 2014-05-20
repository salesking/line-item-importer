class Import < ActiveRecord::Base
  include UserReference

  has_many :data_rows, dependent: :destroy
  has_one  :document_data_row
  has_many :line_item_data_rows
  belongs_to :attachment, inverse_of: :imports

  default_scope ->{order('imports.id desc')}

  validates :attachment, presence: true

  after_save :populate_data_rows

  def title
    title = I18n.t('imports.title_success', count: data_rows.success.count)
    if (failed = data_rows.failed.count) > 0
      [title, I18n.t('imports.title_failed', count: failed)].to_sentence
    else
      title
    end
  end

  def preview(size = 3)
    mapping_elements = attachment.mapping.mapping_elements
    [mapping_elements.collect(&:target)] + attachment.rows[1..size].collect do |row|
      attachment.mapping.mapping_elements.collect do |mapping_element|
        mapping_element.convert(row)
      end
    end
  end

  # An import is successful if no rows failed
  def success?
    data_rows.exists? && !data_rows.failed.exists?
  end

  private

  def populate_data_rows
    data_to_populate = attachment.rows.drop(1)
    case self.import_type
      when :line_item; then populate_many_documents(data_to_populate)
      else populate_one_document(data_to_populate) if attachment.mapping.valid_document_type?
    end
    data_rows(true)
  end

  def populate_one_document(data_to_populate)
    self.document_data_row.create!(data: data_to_populate)
    .map do |row|
    end
  end

  def populate_many_documents(data_to_populate)
    data_to_populate.map do |row|
      self.line_item_data_rows.create!(data: row)
    end
  end

end
