class StrongParameterInstallationsController < ApplicationController
  def show
  end

  def update
    @strong_parameter_installation = StrongParameterInstallation.find(params[:id])

    respond_to do |format|
      if @strong_parameter_installation.update_attributes(strong_parameter_installation_params)
        format.html { redirect_to(strong_parameter_installation_path(@strong_parameter_installation)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private

  def strong_parameter_installation_params
    params.require(:strong_parameter_installation).permit(:name, :area_history_attributes => [:id, :value, :valid_from, :_destroy])
  end
end
