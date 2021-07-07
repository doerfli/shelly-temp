class DevicesController < ApplicationController

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
        

        @hum = Value.includes(:type).where(device: @device, type: { name: 'hum' }).order(created_at: :desc).first
        @temp = Value.includes(:type).where(device: @device, type: { name: 'temp' }).order(created_at: :desc).first
    end

end
