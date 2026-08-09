class Device < ApplicationRecord

    has_many :values

    def last_temp_value
        latest_reading('temp')&.value || 'N/A'
    end

    def last_hum_value
        latest_reading('hum')&.value || 'N/A'
    end

    def last_update_at
        latest_reading('temp')&.created_at || Time.now
    end

    def last_update_timestamp
        latest_reading('temp')&.created_at&.strftime("%d.%m.%y %R") || 'N/A'
    end

    # Newest reading of a type. Memoized because a single page asks for the same
    # one several times over.
    def latest_reading(type_name)
        @latest_readings ||= {}
        @latest_readings.fetch(type_name) {
            @latest_readings[type_name] = readings(type_name).order(created_at: :desc).first
        }
    end

    # The reading that was still the station's reported state one window before
    # the newest reading: the last one at or before the cutoff, not the one
    # nearest to it. Since the station only reports on change, that value held
    # until the next report.
    #
    # The cutoff is anchored on the newest reading rather than on now. With a
    # `now` anchor a station that last reported five hours ago would find its
    # own newest reading in the reference slot and always look steady.
    def reference_reading(type_name, window)
        latest = latest_reading(type_name)
        return nil if latest.nil?

        cutoff = latest.created_at - Trend::WINDOWS.fetch(window)
        readings(type_name).where(created_at: ..cutoff).order(created_at: :desc).first
    end

    def trend(type_name, window)
        Trend.between(latest: latest_reading(type_name),
                      reference: reference_reading(type_name, window),
                      type_name: type_name,
                      window: window)
    end

    private

    # Values of one type, skipping rows where the station sent nothing. Value has
    # no validations, so a request without the query parameter is persisted with
    # a nil value.
    def readings(type_name)
        values.joins(:type).where(type: { name: type_name }).where.not(value: nil)
    end

end
