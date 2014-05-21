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
  CONVERT_TYPES = %w(enum date join).freeze

  belongs_to :mapping

  validates :conversion_type, inclusion: {in: CONVERT_TYPES, message: "Unknown conversion type %{value}"}, allow_blank: true

  serialize :conversion_options

  scope :for_line_items, -> { where(model_to_import: 'line_item') }
  scope :for_documents,  -> { where(model_to_import: 'document')  }

  # @param [Array] data_row
  def convert(data_row)
    if conversion_type && self.respond_to?("convert_#{conversion_type}")
      self.send("convert_#{conversion_type}", data_row)
    else # simple field mapping
      data_row[source.to_i]
    end
  end

  #  convert_opts = {"male":"Herr","female":"Frau"}
  def convert_enum(data_row)
    val = data_row[source.to_i]
    res = conversion_options.detect {|trg_val, src_val| val == src_val }
    res && res[0]
  end

  def convert_date(data_row)
    val = data_row[source.to_i]
    date = Date.strptime(val, conversion_options['date']) rescue val
    date.is_a?(Date) ? date.strftime("%Y.%m.%d") : val
  end

  # == Params
  # <Array>:. Incoming csv fields
  def convert_join(data_row)
    source.split(',').map{|i| data_row[i.to_i] }.join(' ')
  end
end
