# Mapping is a container for a set of mapping elements
class Mapping < ActiveRecord::Base
  include UserReference

  DOCUMENT_TYPES = %w(invoice order estimate credit_note).freeze
  IMPORT_TYPES   = %w(document line_item).freeze
  has_many :attachments,      dependent: :nullify, inverse_of: :mapping
  has_many :mapping_elements, dependent: :destroy

  accepts_nested_attributes_for :mapping_elements

  validates :import_type,   inclusion: {in: IMPORT_TYPES  }
  validates :document_type, inclusion: {in: DOCUMENT_TYPES}
  # Salesking UUID-s are always 22-chars long
  validates :document_id, format: {with: /\A[a-zA-Z0-9\-_]{22}\z/, allow_blank: true}

  validates :mapping_elements, presence: true

  before_validation :check_if_document_is_present_and_is_draft

  default_scope ->{order('mappings.id desc')} # should this be here?

  scope :by_company, lambda {|company_id| where(company_id: company_id)}
  scope :with_fields, -> {
    joins(:mapping_elements).
    select('mappings.id, count(mapping_elements.id) as element_count').
    group('mappings.id')
  }

  def title
    I18n.t('mappings.title', count: mapping_elements.count, fields: mapping_elements.collect(&:target).to_sentence)
  end

  private
  def check_if_document_is_present_and_is_draft
    if !self.document_id.empty?
      document = Sk.const_get(self.document_type.classify).find(self.document_id)
      if document.status != 'draft'
        # errors[:base] << "Dokument ist kein Draft mehr."
        errors[:base] << I18n.t('activerecord.errors.models.mapping.document_type_invalid')
      end
    end
  end

end
