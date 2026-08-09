require "test_helper"

class TrendTest < ActiveSupport::TestCase

  Reading = Struct.new(:value, :created_at)

  def reading(value, ago)
    Reading.new(value.to_s, ago.ago)
  end

  def build(latest_value, reference_value, type_name: "temp", window: :short,
            latest_ago: 5.minutes, reference_ago: 4.hours)
    Trend.between(latest: reading(latest_value, latest_ago),
                  reference: reading(reference_value, reference_ago),
                  type_name: type_name,
                  window: window)
  end

  test "rising past the dead zone points up" do
    trend = build(22.0, 19.0)
    assert trend.known?
    assert_equal :up, trend.direction
    assert_in_delta 3.0, trend.delta, 0.001
  end

  test "falling past the dead zone points down" do
    assert_equal :down, build(19.0, 22.0).direction
  end

  test "movement inside the dead zone is steady" do
    trend = build(21.2, 21.0)
    assert_equal :steady, trend.direction
    assert trend.known?
    assert_not trend.moving?
  end

  test "drift below the dead zone is steady, movement above it is not" do
    assert_equal :steady, build(21.25, 21.0).direction
    assert_equal :up, build(21.5, 21.0).direction
  end

  test "the strong tier starts at its threshold" do
    assert_not build(22.4, 21.0).strong?
    assert build(22.5, 21.0).strong?
    assert build(19.5, 21.0).strong?
  end

  test "humidity uses its own thresholds" do
    # 1.5 would already be movement for temperature, but not for humidity
    assert_equal :steady, build(58.5, 60.0, type_name: "hum").direction
    assert_equal :down, build(57.0, 60.0, type_name: "hum").direction
    assert build(52.0, 60.0, type_name: "hum").strong?
  end

  test "the long window ignores drift the short window reports" do
    assert_equal :up, build(21.375, 21.0, window: :short).direction
    assert_equal :steady, build(21.375, 21.0, window: :long, reference_ago: 26.hours).direction
  end

  test "no trend when the station has gone quiet" do
    trend = build(22.0, 19.0, latest_ago: 25.hours, reference_ago: 29.hours)
    assert_not trend.known?
    assert_not trend.moving?
    assert_nil trend.direction
  end

  test "no trend without a reference reading" do
    trend = Trend.between(latest: reading(22.0, 5.minutes), reference: nil,
                          type_name: "temp", window: :short)
    assert_not trend.known?
  end

  test "no trend without a latest reading" do
    trend = Trend.between(latest: nil, reference: reading(19.0, 4.hours),
                          type_name: "temp", window: :short)
    assert_not trend.known?
  end

  test "no trend when the reference is beyond the age cap" do
    assert build(22.0, 19.0, reference_ago: 11.hours).known?
    assert_not build(22.0, 19.0, reference_ago: 13.hours).known?
  end

  test "the long window tolerates an older reference than the short one" do
    assert build(22.0, 19.0, window: :long, reference_ago: 30.hours).known?
    assert_not build(22.0, 19.0, window: :long, reference_ago: 37.hours).known?
  end

  test "no trend for an unknown measurement type" do
    assert_not build(22.0, 19.0, type_name: "pressure").known?
  end

  test "no trend when the reference is not older than the latest reading" do
    trend = build(22.0, 19.0, latest_ago: 4.hours, reference_ago: 4.hours)
    assert_not trend.known?
  end

  test "elapsed reports the real gap to the reference" do
    trend = build(22.0, 19.0, latest_ago: 10.minutes, reference_ago: 8.hours)
    assert_in_delta 7.hours + 50.minutes, trend.elapsed, 1
  end

end
