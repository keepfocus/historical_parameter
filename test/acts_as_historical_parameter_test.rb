require 'test_helper'

class ActsAsHistoricalParameterTest < ActiveSupport::TestCase
  test "historic parameter works like regualar attribute" do
    installation = Installation.new
    installation.area = 42.0
    assert_equal 42.0, installation.area
  end

  test "historic parameter ignores set to nil value" do
    installation = Installation.new
    installation.area = 42.0
    installation.area = nil
    assert_equal 42.0, installation.area
  end

  test "historic parameter can be undefined" do
    installation = Installation.new
    assert_nil installation.area
  end

  test "historic parameter has a history" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 01, 01))
    installation.set_area(43, Time.zone.local(2010, 02, 01))
    assert_equal 43, installation.area
    installation.save
    expected = [
      [Time.zone.local(2010, 01, 01), Time.zone.local(2010, 02, 01), 42],
      [Time.zone.local(2010, 02, 01), nil, 43]
    ]
    assert_equal expected, installation.area_values
  end

  test "callback history within timeslot for area #1" do
    installation = Installation.new
    installation.set_area(10, Time.zone.local(2010, 1, 1))
    installation.set_area(20, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 1, 1), Time.zone.local(2010, 2, 1)) {1}
    mock(dummy).calculate(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) {2}
    result = installation.area_sum(Time.zone.local(2010, 1, 1), Time.zone.local(2010, 3, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 1*10 + 2*20, result
  end

  test "callback history within timeslot for area #2" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) {2}
    result = installation.area_sum(Time.zone.local(2010, 2, 1), Time.zone.local(2010, 3, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 2*43, result
  end

  test "callback history within timeslot for area #3" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 2, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) {1}
    result = installation.area_sum(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 42, result
  end

  test "callback history within timeslot for area #5" do
    installation = Installation.new
    installation.set_area(42, Time.zone.local(2010, 1, 1))
    installation.set_area(43, Time.zone.local(2010, 3, 1))
    installation.save
    dummy = Object.new
    mock(dummy).calculate(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) {1}
    result = installation.area_sum(Time.zone.local(2010, 1, 15), Time.zone.local(2010, 2, 1)) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 42, result
  end

  test "callback history within timeslot for area #4" do
    start_time = 2.days.ago.beginning_of_day
    installation = Installation.new
    installation.set_area(12, start_time - 1.day)
    installation.save
    dummy = Object.new
    mock(dummy).calculate(start_time, start_time + 1.day) {240}
    result = installation.area_sum(start_time, start_time + 1.day) do |t1, t2, value|
      dummy.calculate(t1, t2) * value
    end
    assert_equal 240*12, result
  end

  test "edit parameter history through model" do
    installation = Installation.new
    installation.update_attributes({
      :area_history_attributes => [
        {:valid_from => Time.zone.local(2010, 1, 1), :value => 42},
        {:valid_from => Time.zone.local(2010, 2, 1), :value => 43}
      ]
    })
    installation.save
    assert_equal 43, installation.area
    expected = [
      [Time.zone.local(2010, 01, 01), Time.zone.local(2010, 02, 01), 42],
      [Time.zone.local(2010, 02, 01), nil, 43]
    ]
    assert_equal expected, installation.area_values
  end

  test "destroy line in history through model" do
    installation = Installation.new
    installation.update_attributes({
      :area_history_attributes => [
        {:valid_from => Time.zone.local(2010, 1, 1), :value => 42},
        {:valid_from => Time.zone.local(2010, 2, 1), :value => 43}
      ]
    })
    installation.save
    assert_difference 'installation.area_history.count', -1 do
      installation.update_attributes({
        :area_history_attributes => [
          {:id => installation.area_history.first.id, :_destroy => true}
        ]
      })
    end
  end

  test "history sum will not yield an invalid period" do
    installation = Installation.new
    installation.set_area(10, Time.zone.local(2010, 01, 01))
    installation.set_area(20, Time.zone.local(2011, 01, 01))
    installation.set_area(30, Time.zone.local(2012, 01, 01))
    installation.set_area(40, Time.zone.local(2013, 01, 01))
    installation.set_area(50, Time.zone.local(2014, 01, 01))
    installation.set_area(60, Time.zone.local(2015, 01, 01))
    installation.save
    start_time = DateTime.new(2013,1,1)
    result = installation.area_sum(start_time, start_time + 1.month) do |t1, t2, value|
      assert_operator t2, :>=, t1
      0
    end
  end

end
