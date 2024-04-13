--- @param src number
--- @param data NotifyProps
function server.notify(src, data)
    TriggerClientEvent('ox_lib:notify', src, data)
end

function server.createDatabase(name, columns)
    local query = 'CREATE TABLE IF NOT EXISTS ' .. name .. ' ('
    for _, value in pairs(columns) do
        query = query .. value.name .. ' ' .. value.type .. ', '
    end
    query = query .. 'PRIMARY KEY (id))'

    MySQL.Async.execute(query, {}, function(rowsChanged)
        if rowsChanged > 0 then
            print('Created database ' .. name)
        end
    end)
end

server.date = {
    --- Add time to a date
    --- @param date any
    --- @param years? number
    --- @param months? number
    --- @param days? number
    --- @param hours? number
    --- @param minutes? number
    --- @param seconds? number
    --- @return string|osdate
    add = function(date, years, months, days, hours, minutes, seconds)
        local newDate = os.time(date)
        newDate = newDate + (years or 0) * 31536000
        newDate = newDate + (months or 0) * 2628000
        newDate = newDate + (days or 0) * 86400
        newDate = newDate + (hours or 0) * 3600
        newDate = newDate + (minutes or 0) * 60
        newDate = newDate + (seconds or 0)

        return os.date('*t', newDate)
    end,
    --- generateExpiresString
    --- @param seconds number
    --- @return string
    generateExpiresString = function(seconds)
        local date = server.date.add(os.date('*t'), 0, 0, 0, 0, 0, seconds)
        return ('%02d.%02d.%04d %02d:%02d:%02d'):format(date.day, date.month, date.year, date.hour, date.min, date.sec)
    end
}