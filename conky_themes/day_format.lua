function conky_format_day()
    -- Get the current day
    local day = os.date("%A")

    -- Capitalize the first letter, lowercase the rest
    local formatted_day = string.sub(day, 1, 1):upper() .. string.sub(day, 2):lower()

    -- Add spaces for shorter day names to adjust the position
    if string.len(day) <= 6 then
        offset_spaces = " "  -- Add some spaces for adjustment
        return offset_spaces .. formatted_day
    else
        -- Return the formatted day without additional spaces
        return formatted_day
    end
end


