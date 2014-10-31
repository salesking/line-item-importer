class MappingsController < ApplicationController
  include ApplicationHelper
  load_and_authorize_resource :attachment, only: [:new, :create]
  load_and_authorize_resource
  skip_load_resource only: [:create, :check_document]

  before_filter :include_gon_translation

  def create
    if params[:reuse] && !params[:mapping_id].empty?
      @mapping = Mapping.find params[:mapping_id]
    else
      @mapping = Mapping.new(mapping_params)
      @mapping.user = current_user
    end
    
    @mapping.attachments << @attachment

    if @mapping.save
      redirect_to new_attachment_import_url(@attachment)
    else
      flash[:error]
      render :new
    end
  end

  def destroy
    if @mapping.destroy
      flash[:success] = I18n.t('imports.destroyed_successfully')
    else
      flash[:error]  = I18n.t('imports.destroy_failed')
    end
    redirect_to attachments_path
  end

  def check_document
    mapping = Mapping.find params[:mapping_id]
    if !mapping.document_id.empty?
      document = Sk.const_get(mapping.document_type.classify).find(mapping.document_id)
      salesking_link = salesking_document_link(mapping.document_type, document.id)
      data = {status: document.status, title: document.title, document_id: document.id, link: salesking_link}
    else
      data = {status: "no_document_available"}
    end
    render :json => data, :status => :ok
  end

  private
  def mapping_params
    params.require(:mapping).permit(:document_type, :import_type, :document_id, mapping_elements_attributes: [:id, :source, :target, :source, :conversion_type, :conversion_options, :import_id, :model_to_import])
  end

  def include_gon_translation
    gon[:document_id_placeholder] = t('mappings.form.document_id_placeholder')
  end
end
