class InstallationsController < ApplicationController
  def show
  end

  def update
    @installation = Installation.find(params[:id])
    return if handle_add_value(@installation, :area_history, installation_params)

    respond_to do |format|
      if @installation.update(installation_params)
        format.html { redirect_to(installation_path(@installation)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def installation_params
    params.require(:installation).permit(:name, :area_history_attributes => [:value, :valid_from])
  end
end
