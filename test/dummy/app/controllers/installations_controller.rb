class InstallationsController < ApplicationController
  def show
  end

  def update
    @installation = Installation.find(params[:id])
    return if handle_add_value(@installation, :area_history, params[:installation])

    respond_to do |format|
      if @installation.update_attributes(params[:installation])
        format.html { redirect_to(installation_path(@installation)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
