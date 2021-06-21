class MeasurementsController < ApplicationController

    def new
        @device = Device.find_or_create_by(ident: params[:id])
        
        @type_hum = Type.find_or_create_by(name: "hum")
        @type_temp = Type.find_or_create_by(name:"temp")
        
        @value_hum = Value.new
        @value_hum.value = params[:hum]
        @value_hum.type = @type_hum
        @value_hum.device = @device
        @value_hum.save

        @value_temp = Value.new
        @value_temp.value = params[:temp]
        @value_temp.type = @type_temp
        @value_temp.device = @device
        @value_temp.save
    end

end
