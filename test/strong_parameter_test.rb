require File.dirname(__FILE__) + '/test_helper'

class StrongParameterHistoricalControllerAddonsTest < ActionController::TestCase
  tests StrongParameterInstallationsController

  def setup
    Rails.application.routes.draw { resources :strong_parameter_installations }
    @routes = Rails.application.routes
  end

  test "Update works for save new state" do
    @strong_parameter_installation = StrongParameterInstallation.create
    @strong_parameter_installation.update_attribute :name, 'original'
    assert_equal 0, StrongParameterInstallation.find(@strong_parameter_installation.to_param).area_history.count
    put :update, :id => @strong_parameter_installation.to_param, :strong_parameter_installation => {
      :area_history_attributes => {
        '1234567' => {:value => 42, :valid_from => Time.zone.local(2010, 1, 1)},
        '1234568' => {:value => 43, :valid_from => Time.zone.local(2010, 2, 1)}
      } ,
      :name => "changed"
    }
    assert_redirected_to strong_parameter_installation_path(@strong_parameter_installation)
    assert_equal "changed", StrongParameterInstallation.find(@strong_parameter_installation.to_param).name
    assert_equal 2, StrongParameterInstallation.find(@strong_parameter_installation.to_param).area_history.count
    assert_equal 43, StrongParameterInstallation.find(@strong_parameter_installation.to_param).area
  end
end
