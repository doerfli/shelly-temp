module DevicesHelper

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

    def bg_color_temp(value, color_conditions = COLOR_CONDITIONS_TEMP)
        return "bg-color-gray-200" if color_conditions.nil?
        begin
            num = value.to_f 
        rescue 
            return "bg-color-gray-200"
        end
        bg_class = "bg-color-gray-200"

        color_conditions.each{ |c| 
            upper = c[:u]
            lower = c[:l]
            bg_class = c[:cls] if (num >= lower && num < upper)
        }

        bg_class
    end

    def bg_color_hum(value, color_conditions = COLOR_CONDITIONS_HUM)
        return "bg-color-gray-200" if color_conditions.nil?
        begin
            num = value.to_f 
        rescue 
            return "bg-color-gray-200"
        end
        bg_class = "bg-color-gray-200"

        color_conditions.each{ |c| 
            upper = c[:u]
            lower = c[:l]
            bg_class = c[:cls] if (num >= lower && num < upper)
        }

        bg_class
    end

end
