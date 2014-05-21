class DataRow < ActiveRecord::Base
  belongs_to :import

  attr_writer :data

  scope :failed,  -> {where(external_id: nil)}
  scope :success, -> {where('data_rows.external_id IS NOT NULL')}
end
