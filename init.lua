require 'utils.shared.main'

Config = require 'data.Config'
_print = print
debugMode = Config.debug
lib.locale()

function print(...)
    if debugMode.enabled then
        local env = lib.context
        local currentTime = env == 'server' and os.date('%H:%M:%S') or lib.callback.await('getTime', false)
        _print('^4[' .. currentTime .. '][' .. env:upper() .. ']^7 ', ...)
    end
end

if lib.context == 'server' then
    Server = {}

    lib.callback.register('getTime', function()
        return os.date('%H:%M:%S')
    end)

    require 'utils.server.main'
    require 'utils.server.mysql'
    return require 'server'
end

Client = {}
require 'utils.client.other'
require 'utils.client.ox'
require 'client'