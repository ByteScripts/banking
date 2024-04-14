return {
    debug = {
        enabled = true
    },
    restricted = {
        'group.admin'
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
    end,
    atmBlips = true,
    textUi = {
        show = function(text)
            lib.showTextUI(text)
        end,
        hide = function()
            lib.hideTextUI()
        end
    },
    helpNotification = function(text)
        ESX.ShowHelpNotification(text)
    end,
    atmOptions = {
        ['balance'] = true,
        -- ['iban'] = true,
        ['withdraw'] = true,
        -- ['deposit'] = true,
        -- ['transfer'] = true,
        -- ['transactions'] = true,
        -- ['change_pin'] = true,
        -- ['close_account'] = true,
    }
}