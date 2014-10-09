# A mapping element connects source with targed field. It further does
# a conversion if needed
#
# == Conversions:
# - join: merges multiple incoming fields into a target
# - enum: maps source strings to enum target values
#
# - split: split source field into multiple target fields
#
class MappingElement < ActiveRecord::Base
  CONVERT_TYPES = %w(enum date join price).freeze

  belongs_to :mapping

  validates :conversion_type, inclusion: {in: CONVERT_TYPES, message: "Unknown conversion type %{value}"}, allow_blank: true
  validates :model_to_import, inclusion: {in: %w(line_item document)}

  # validates :mapping, presence: true

  serialize :conversion_options

  scope :for_line_items, -> { where(model_to_import: 'line_item') }
  scope :for_documents,  -> { where(model_to_import: 'document')  }

  # @param [Array] data_row
  def convert(data_row)
    conversion_method = "convert_#{conversion_type}"
    if conversion_type && self.respond_to?(conversion_method)
      self.send(conversion_method, data_row)
    else # simple field mapping
      source_value(data_row)
    end
  end

  #  convert_opts = {"male":"Herr","female":"Frau"}
  def convert_enum(data_row)
    value = source_value(data_row)
    res = conversion_options.detect {|trg_val, src_val| value == src_val }
    res && res[0]
  end

  def convert_date(data_row)
    value = source_value(data_row)
    date = Date.strptime(value, conversion_options['date']) rescue Chronic.parse(value)
    date.is_a?(Date) ? date.strftime("%Y.%m.%d") : value
  end

  def convert_price(data_row)
    value = source_value(data_row)
    value.try(:match, /([0-9\.,]+)/).try(:[], 1) || value
  end

  # == Params
  # <Array>:. Incoming csv fields
  def convert_join(data_row)
    source.split(',').map{|i| data_row[i.to_i] }.join(' ')
  end

  private
  def source_value(data_row)
    data_row[source.to_i]
  end
end
