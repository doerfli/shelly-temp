class DisplaysController < ApplicationController

    def show
        @device = Device.find_by(name: params[:id])
        @device = Device.find_by(ident: params[:id]) if @device.nil?
        logger.info @device.ident

        hum_type = Type.find_by(name: 'hum')
        temp_type = Type.find_by(name: 'temp')

        @hum = Value.where(device: @device, type: hum_type).order(created_at: :desc).first
        @temp = Value.where(device: @device, type: temp_type).order(created_at: :desc).first
    end

end
