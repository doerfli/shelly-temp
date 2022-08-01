class DevicesController < ApplicationController
    
    TIMESERIES_RANGE = 7.days

    def index
        @devices = Device.all.order(:name)
    end

    def show
        logger.info params
        @device = Device.find_by(ident: params[:ident])
        if @device.name.nil?
            @title = "#{@device.ident} Temp&Hum"
        else
            @title = "#{@device.name} Temp&Hum" 
        end

        @hum = Value.includes(:type)
                    .where(device: @device, type: { name: 'hum' })
                    .order(created_at: :desc).first
        @temp = Value.includes(:type)
                    .where(device: @device, type: { name: 'temp' })
                    .order(created_at: :desc).first
        
        # get timeseries for charts
        @temp_l7d = Value.includes(:type)
                    .where(device: @device, type: { name: 'temp' }, created_at: TIMESERIES_RANGE.ago..Time.now)
                    .order(created_at: :asc).filter{ |v| ! v.value.nil? }
        @temp_l7d_min = (@temp_l7d.map{ |v| v.value.to_f }.min - 2).floor
        @temp_l7d_max = (@temp_l7d.map{ |v| v.value.to_f }.max + 2).ceil
        @hum_l7d = Value.includes(:type)
                    .where(device: @device, type: { name: 'hum' }, created_at: TIMESERIES_RANGE.ago..Time.now)
                    .order(created_at: :asc).filter{ |v| ! v.value.nil? }
        @hum_l7d_min = (@hum_l7d.map{ |v| v.value.to_f }.min - 2).floor
        @hum_l7d_max = (@hum_l7d.map{ |v| v.value.to_f }.max + 2).ceil
    end

end
