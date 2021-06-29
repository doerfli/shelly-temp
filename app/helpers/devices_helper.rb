module DevicesHelper

    def bg_color(value, color_conditions)
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
