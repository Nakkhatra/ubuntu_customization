function conky_format_day()
    -- Get the current day
    local day = os.date("%A")

    -- Capitalize the first letter, lowercase the rest
    local formatted_day = string.sub(day, 1, 1):upper() .. string.sub(day, 2):lower()

    -- Calculate spacing to center align day names
    -- Wednesday (9 chars) is the longest day name
    local max_length = 9
    local day_length = string.len(day)
    local spaces_needed = math.floor((max_length - day_length) / 2)

    local offset_spaces = string.rep(" ", spaces_needed)

    return offset_spaces .. formatted_day
end



