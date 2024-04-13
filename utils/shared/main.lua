shared = {
    table = {
        ---Find a value in a table
        ---@param tbl table
        ---@param key any
        ---@param value any
        ---@return any
        ---@return any
        find = function(tbl, key, value)
            for k, v in pairs(tbl) do
                if v[key] == value then
                    return v, k
                end
            end
        end,
        ---Filter something from a table
        ---@param tbl table
        ---@param callback fun(value: any, key: any): boolean
        ---@return table
        filter = function(tbl, callback)
            local new = {}
            for k, v in pairs(tbl) do
                if callback(v, k) then
                    table.insert(new, v)
                end
            end
            return new
        end,
        ---Sort a table
        ---@param tbl table
        ---@param callback fun(a: any, b: any): boolean
        ---@return table
        sort = function(tbl, callback)
            table.sort(tbl, callback)
            return tbl
        end,
        ---Check if a table contains a value
        ---@param tbl table
        ---@param value any
        ---@return boolean
        contains = function(tbl, value)
            for _, v in pairs(tbl) do
                if v == value then
                    return true
                end
            end
            return false
        end,
        ---Check if a table contains a key
        ---@param tbl table
        ---@return any
        map = function(tbl, callback)
            local new = {}
            for k, v in pairs(tbl) do
                new[k] = callback(v, k)
            end
            return new
        end,
        --- Serialize a table
        ---@param array table
        ---@return table
        serializeArray = function(array)
            return shared.table.map(array, function(value)
                local new = {}
                for k, v in pairs(value) do
                    if type(v) ~= 'function' then
                        new[k] = v
                    end
                end
                return new
            end)
        end,
        --- Get the length of a table
        ---@param tbl table
        ---@return number
        length = function(tbl)
            local count = 0
            for _ in pairs(tbl) do count = count + 1 end
            return count
        end,
    },
    --- Generate a uuid
    ---@return string
    uuid = function()
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        local uuid = string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)

        return uuid
    end,
    --- generates time in seconds
    ---@param hours number
    ---@param minutes number
    ---@param seconds number
    ---@return number
    generateTime = function(hours, minutes, seconds)
        return (hours * 60 * 60) + (minutes * 60) + seconds
    end,
    --- formats time in seconds to a string
    ---@param time number
    ---@return string
    formatTime = function(time)
        local hours = math.floor(time / 60 / 60)
        local minutes = math.floor(time / 60) - (hours * 60)
        local seconds = time - (minutes * 60) - (hours * 60 * 60)

        return ('%02d:%02d:%02d'):format(hours, minutes, seconds)
    end,
    --- format price with , and $
    ---@param price number
    ---@return string
    formatPrice = function(price)
        return ('%s$'):format(string.format('%i', price):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
    end,
    time = {
        --- generates time in seconds
        ---@param hours number
        ---@param minutes number
        ---@param seconds number
        ---@return number
        generate = function(hours, minutes, seconds)
            return (hours * 60 * 60) + (minutes * 60) + seconds
        end,
        --- formats time in seconds to a string
        ---@param timeInSeconds number
        ---@param format string
        ---@return string
        format = function(timeInSeconds, format)
            local hours = math.floor(timeInSeconds / 60 / 60)
            local minutes = math.floor(timeInSeconds / 60) - (hours * 60)
            local seconds = timeInSeconds - (minutes * 60) - (hours * 60 * 60)

            local string = ('%s Stunden %s Minuten %s Sekunden'):format(hours, minutes, seconds)
            return string
        end,
    }
}

shared.onResourceStart = setmetatable({}, {
    __call = function(self, cb)
        AddEventHandler('onResourceStart', function(resourceName)
            if resourceName == GetCurrentResourceName() then
                local players = GetPlayers()
                cb(players)
            end
        end)
    end
})

shared.onResourceStop = setmetatable({}, {
    __call = function(self, cb)
        AddEventHandler('onResourceStop', function(resourceName)
            if resourceName == GetCurrentResourceName() then
                local players = GetPlayers()
                cb(players)
            end
        end)
    end
})