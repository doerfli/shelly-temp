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

    TREND_GLYPHS = { :up => "↑", :down => "↓", :steady => "→" }
    # The 800 shades stay legible both on the white device list and on the
    # pastel bg-*-300 value boxes.
    TREND_COLORS = { :up => "text-red-800", :down => "text-blue-800", :steady => "text-gray-700" }
    TREND_LABELS = { :up => "rising", :down => "falling", :steady => "steady" }
    TREND_UNITS = { "temp" => "℃", "hum" => "%" }

    # Bare direction glyph, for the device list. Doubled and bold on the strong
    # tier. Nothing at all when the trend cannot be established.
    def trend_marker(trend)
        return "".html_safe unless trend.known?

        glyph = TREND_GLYPHS.fetch(trend.direction)
        classes = [TREND_COLORS.fetch(trend.direction)]
        classes << "font-bold" if trend.strong?

        content_tag(:span, trend.strong? ? glyph * 2 : glyph,
                    :class => classes.join(" "),
                    :title => trend_change_label(trend),
                    :aria => { :label => TREND_LABELS.fetch(trend.direction) })
    end

    # Glyph plus the numbers behind it, for the value boxes on the device page.
    def trend_summary(trend)
        return "".html_safe unless trend.known?

        safe_join([trend_marker(trend), trend_change_label(trend)], " ")
    end

    # The elapsed time is the real gap to the reference reading, which is often
    # longer than the window: a station reporting every 8 hours gives an 8 hour
    # old reference for the 3 hour window. Showing it keeps the marker honest.
    def trend_change_label(trend)
        "#{format('%+.1f', trend.delta)} #{TREND_UNITS.fetch(trend.type_name, '')} over #{trend_elapsed_label(trend.elapsed)}"
    end

    def trend_elapsed_label(seconds)
        minutes = (seconds / 60.0).round
        return "#{minutes}min" if minutes < 60
        "#{(seconds / 3600.0).round}h"
    end

end
