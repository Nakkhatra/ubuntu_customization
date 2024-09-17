function conky_format_day()
    -- Get the current day
    local day = os.date("%A")

    -- Capitalize the first letter, lowercase the rest
    local formatted_day = string.sub(day, 1, 1):upper() .. string.sub(day, 2):lower()

    -- Return the formatted day
    return formatted_day
end


