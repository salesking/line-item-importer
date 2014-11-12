class ImportsController < ApplicationController
  load_and_authorize_resource :attachment, only: [:new, :create, :destroy]
  load_and_authorize_resource
  before_filter :init_import, only: [:new, :create]

  def create
    initialize_salesking_connection
    if @import.save
      redirect_to @import
      Sk.reset_connection
    else
      Sk.reset_connection
      render action:  "new"
    end
  end

  def destroy
    if @import.destroy
      flash[:success] = I18n.t('mappings.destroyed_successfully')
    else
      flash[:error]  = I18n.t('mappings.destroy_failed')
    end
    redirect_to attachments_path
  end

  private

  def init_import
    @import = Import.new(attachment: @attachment)
    @import.user = current_user
  end
end
