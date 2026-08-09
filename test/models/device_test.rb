require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  include ActiveRecord::Assertions::QueryAssertions

  setup do
    @device = Device.create!(ident: "trendtest")
  end

  def record(value, ago, type_name = "temp")
    Value.create!(device: @device,
                  type: Type.find_by(name: type_name),
                  value: value&.to_s,
                  created_at: ago.ago)
  end

  test "the reference is the last reading at or before the cutoff, not the nearest one" do
    record(18.0, 10.hours)
    record(19.0, 4.hours)
    record(21.0, 2.hours)
    record(22.0, 1.minute)

    # The 2h reading sits closer to the 3h cutoff, but the 4h reading is the one
    # that was still the station's reported state 3 hours ago.
    assert_in_delta 3.0, @device.trend("temp", :short).delta, 0.001
  end

  test "the window is anchored on the newest reading rather than on now" do
    record(19.0, 13.hours)
    record(22.0, 5.hours)

    trend = @device.trend("temp", :short)
    assert trend.known?, "a station that last reported 5h ago still has a trend"
    assert_equal :up, trend.direction
    assert_in_delta 3.0, trend.delta, 0.001
  end

  test "a quiet station on an 8 hour cadence still gets a short window trend" do
    record(19.0, 16.hours)
    record(20.4, 8.hours)
    record(22.1, 10.minutes)

    trend = @device.trend("temp", :short)
    assert_equal :up, trend.direction
    assert trend.strong?
    assert_in_delta 1.7, trend.delta, 0.001
  end

  test "no trend from a single reading" do
    record(22.0, 5.minutes)

    assert_not @device.trend("temp", :short).known?
    assert_not @device.trend("temp", :long).known?
  end

  test "no trend without any readings" do
    assert_not @device.trend("temp", :short).known?
    assert_equal "N/A", @device.last_temp_value
    assert_equal "N/A", @device.last_update_timestamp
  end

  test "temperature and humidity are tracked separately" do
    record(19.0, 4.hours)
    record(22.0, 5.minutes)
    record(60.0, 4.hours, "hum")
    record(52.0, 5.minutes, "hum")

    assert_equal :up, @device.trend("temp", :short).direction
    assert_equal :down, @device.trend("hum", :short).direction
  end

  test "readings without a value are ignored" do
    record(19.0, 4.hours)
    record(22.0, 30.minutes)
    record(nil, 1.minute)

    assert_equal "22.0", @device.last_temp_value
    assert_in_delta 3.0, @device.trend("temp", :short).delta, 0.001
  end

  test "the newest reading is fetched once per type" do
    record(22.0, 5.minutes)

    @device.last_temp_value
    assert_no_queries do
      @device.last_temp_value
      @device.last_update_at
      @device.last_update_timestamp
    end
  end

end
