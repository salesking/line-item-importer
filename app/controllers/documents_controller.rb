class DocumentsController < ApplicationController
  respond_to :json

  def autocomplete
    initialize_salesking_connection
    type = document_type
    return if type.nil?
    @results = Sk.const_get(type).where(permitted_params.merge(filter: {status_draft: 1}))
    Sk.reset_connection
    render json: {results: process_results, total_pages: @results.total_pages}
  end

  protected

  def document_type
    Mapping::DOCUMENT_TYPES.include?(params[:type]) ? params[:type].classify : render_wrong_type
  end

  def render_wrong_type
    render json: {error: 'Wrong document type'}, status: :forbidden
  end

  def process_results
    @results.map do |document|
      {
        id: document.id,
        name: (document.title.presence || contact_string(document.contact).presence || '[ >> ]'),
        address: document.address_field.split(/\r?\n/).take(2).join("\n")
      }
    end
  end

  def contact_string(contact)
    return nil unless contact
    texts = []
    texts << contact.organisation.presence
    texts << "#{contact.first_name} #{contact.last_name}".presence
    texts.compact.join(' - ')
  end

  def permitted_params
    params.permit(:q, :per_page, :page)
  end

end
