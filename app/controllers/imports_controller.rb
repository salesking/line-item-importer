class ImportsController < ApplicationController
  load_and_authorize_resource :attachment, only: [:new, :create]
  load_and_authorize_resource
  before_filter :init_import, only: [:new, :create]

  def create
    initialize_salesking_connection
    if @import.save
      redirect_to @import
    else
      render action:  "new"
    end
  end

  private

  def init_import
    @import = Import.new(attachment: @attachment)
    @import.user = current_user
  end
end
