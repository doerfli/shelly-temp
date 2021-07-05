class DevicesController < ApplicationController

    def index
        @devices = Device.all.order(:name)
    end

    def show
        logger.info params
        @device = Device.find_by(name: params[:id])
        @device = Device.find_by(ident: params[:id]) if @device.nil?
        @title = "#{@device.ident} Temp&Hum"

        @hum = Value.includes(:type).where(device: @device, type: { name: 'hum' }).order(created_at: :desc).first
        @temp = Value.includes(:type).where(device: @device, type: { name: 'temp' }).order(created_at: :desc).first
    end

end
