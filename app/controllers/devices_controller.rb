class DevicesController < ApplicationController

    COLOR_CONDITIONS_TEMP = [
        { :l => -99, :u => 18, :cls => "bg-blue-300"}, 
        { :l => 18, :u => 22, :cls => "bg-teal-300"},
        { :l => 22, :u => 26, :cls => "bg-emerald-300"}, 
        { :l => 26, :u => 28, :cls => "bg-amber-300"}, 
        { :l => 28, :u => 99, :cls => "bg-red-300"}
    ]
    COLOR_CONDITIONS_HUM = [
        { :l => 0, :u => 40, :cls => "bg-blue-300"}, 
        { :l => 40, :u => 60, :cls => "bg-emerald-300"}, 
        { :l => 60, :u => 70, :cls => "bg-amber-300"},
        { :l => 70, :u => 100, :cls => "bg-red-300"}
    ] 

    def index
        @devices = Device.all.order(:name)
        @color_conditions_temp = COLOR_CONDITIONS_TEMP
        @color_conditions_hum = COLOR_CONDITIONS_HUM
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

        @color_conditions_temp = COLOR_CONDITIONS_TEMP
        @color_conditions_hum = COLOR_CONDITIONS_HUM
    end

end
