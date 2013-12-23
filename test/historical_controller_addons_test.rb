require File.dirname(__FILE__) + '/test_helper'

#class InstallationsController < ActionController::Base
#  def rescue_action(e)
#    raise e
#  end
#
#end

class HistoricalControllerAddonsTest < ActionController::TestCase
  tests InstallationsController

  def setup
    Rails.application.routes.draw { resources :installations }
    @routes = Rails.application.routes
  end

  test "Update works for value add" do
    @installation = Installation.create(:name => "original")
      
    put :update, :id => @installation.to_param, :add_area_history_value => "test", :installation => {
      :name => "changed"
    }
    assert_response :success
    assert_not_nil assigns(:installation)
    assert assigns(:installation).area_history.last.new_record?
    assert_equal "changed", assigns(:installation).name
    assert_equal "original", Installation.find(@installation.to_param).name
  end

  test "Update works for save new state" do
    @installation = Installation.create(:name => "original")
    assert_equal 0, Installation.find(@installation.to_param).area_history.count
    put :update, :id => @installation.to_param, :installation => {
      :area_history_attributes => {
        '1234567' => {:value => 42, :valid_from => Time.zone.local(2010, 1, 1)},
        '1234568' => {:value => 43, :valid_from => Time.zone.local(2010, 2, 1)}
      } ,
      :name => "changed"
    }
    assert_redirected_to installation_path(@installation)
    assert_equal "changed", Installation.find(@installation.to_param).name
    assert_equal 43, Installation.find(@installation.to_param).area
    assert_equal 2, Installation.find(@installation.to_param).area_history.count
  end
end
