# Direction of travel of a measurement over a lookback window.
#
# The station only reports when a value moves (0.5℃ / 5% within 5 minutes) plus
# a periodic wakeup, so readings arrive irregularly - three a day when the
# weather is calm, many an hour when it is not. Comparing a fixed number of
# readings is therefore meaningless, and everything here is time based instead.
class Trend

    WINDOWS = {
        short: 3.hours,
        long: 24.hours
    }

    # How far back the reference reading may sit relative to the newest one.
    # An absolute cap rather than a multiple of the window: a quiet station
    # reporting every 8 hours legitimately has an 8 hour old reference for the
    # 3 hour window, and a ratio cap would throw that away.
    MAX_REFERENCE_AGE = {
        short: 12.hours,
        long: 36.hours
    }

    # If the station itself has gone quiet for this long there is no "recently".
    MAX_LATEST_AGE = 24.hours

    # Every reported change event is at least 0.5℃ / 5% big. Smaller deltas only
    # arrive via the periodic wakeup and are genuine slow drift, but sensor
    # jitter is around 0.1℃ / 1% - the dead zones sit between the two. The 24h
    # dead zones are wider because that much movement across a whole day is
    # noise rather than a trend.
    THRESHOLDS = {
        ["temp", :short] => { steady: 0.3, strong: 1.5 },
        ["temp", :long]  => { steady: 0.5, strong: 3.0 },
        ["hum", :short]  => { steady: 2.0, strong: 8.0 },
        ["hum", :long]   => { steady: 3.0, strong: 10.0 }
    }

    attr_reader :delta, :elapsed, :direction, :type_name, :window

    # Builds a trend from the newest reading and the reading that was still the
    # station's reported state one window earlier. Returns an unknown trend
    # rather than nil whenever it cannot say anything, so views never have to
    # nil check.
    def self.between(latest:, reference:, type_name:, window:)
        thresholds = THRESHOLDS[[type_name, window]]
        return unknown(type_name, window) if thresholds.nil?
        return unknown(type_name, window) if latest.nil? || reference.nil?
        return unknown(type_name, window) if latest.created_at < MAX_LATEST_AGE.ago

        elapsed = latest.created_at - reference.created_at
        return unknown(type_name, window) if elapsed <= 0
        return unknown(type_name, window) if elapsed > MAX_REFERENCE_AGE.fetch(window)

        new(delta: latest.value.to_f - reference.value.to_f,
            elapsed: elapsed,
            thresholds: thresholds,
            type_name: type_name,
            window: window)
    end

    def self.unknown(type_name = nil, window = nil)
        new(delta: nil, elapsed: nil, thresholds: nil, type_name: type_name, window: window)
    end

    def initialize(delta:, elapsed:, thresholds:, type_name:, window:)
        @delta = delta
        @elapsed = elapsed
        @type_name = type_name
        @window = window

        if delta.nil? || thresholds.nil?
            @direction = nil
            @strong = false
        elsif delta.abs < thresholds[:steady]
            @direction = :steady
            @strong = false
        else
            @direction = delta.positive? ? :up : :down
            @strong = delta.abs >= thresholds[:strong]
        end
    end

    def known?
        !@direction.nil?
    end

    def strong?
        @strong
    end

    def moving?
        known? && @direction != :steady
    end

end
