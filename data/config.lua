return {
    debug = {
        enabled = true
    },
    item = 'creditcard',
    notify = function(description, type, src)
        type = type or 'info'

        local env = lib.context
        local data = {
            title = locale('title'),
            description = description,
            type = type
        }

        if env == 'server' then
            return lib.notify(src, data)
        end

        lib.notify(data)
    end
}