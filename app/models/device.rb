class Device < ApplicationRecord

    has_many :values

    def last_temp_value
        values.joins(:type).where(type: { name: 'temp'}).order(created_at: :desc).first.value || 'N/A'
    end

    def last_hum_value
        values.joins(:type).where(type: { name: 'hum'}).order(created_at: :desc).first.value || 'N/A'
    end

    def last_update_timestamp
        values.joins(:type).where(type: { name: 'temp'}).order(created_at: :desc).first.created_at.strftime("%d.%m.%y %R") || 'N/A'
    end

end
