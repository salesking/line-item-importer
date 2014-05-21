# Mapping is a container for a set of mapping elements
class Mapping < ActiveRecord::Base
  include UserReference

  DOCUMENT_TYPES = %w(invoice order estimate credit_note)
  IMPORT_TYPES   = (DOCUMENT_TYPES + ['line_item']).freeze
  has_many :mapping_elements, dependent: :destroy
  has_many :attachments, dependent: :nullify, inverse_of: :mapping

  validates :import_type, inclusion: {in: IMPORT_TYPES}

  # Salesking UUID-s are always 22-chars long
  validates :document_id, format: {with: /\A[a-zA-Z0-9\-_]{22}\z/, allow_blank: true}

  default_scope ->{order('mappings.id desc')}

  accepts_nested_attributes_for :mapping_elements
  scope :by_company, lambda {|company_id| where(company_id: company_id)}
  scope :with_fields, -> {
    joins(:mapping_elements).
    select('mappings.id, count(mapping_elements.id) as element_count').
    group('mappings.id'). # fuck up with postgres
    having('count(mapping_elements.id) > 0')
  }

  def title
    I18n.t('mappings.title', count: mapping_elements.count, fields: mapping_elements.collect(&:target).to_sentence)
  end

  def valid_document_type?
    self.class::DOCUMENT_TYPES.include?(import_type.to_s)
  end
end
