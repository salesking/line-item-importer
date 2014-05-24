class MappingsController < ApplicationController
  load_and_authorize_resource :attachment, only: [:new, :create]
  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :include_gon_translation

  def create
    @mapping = Mapping.new(mapping_params)
    @mapping.user = current_user
    @mapping.attachments << @attachment
    if @mapping.save
      redirect_to new_attachment_import_url(@attachment)
    else
      render :new
    end
  end

  private
  def mapping_params
    params.require(:mapping).permit(:document_type, :import_type, :document_id, mapping_elements_attributes: [:id, :source, :target, :source, :conversion_type, :conversion_options, :import_id, :model_to_import])
  end

  def include_gon_translation
    gon[:document_id_placeholder] = t('mappings.form.document_id_placeholder')
  end
end
