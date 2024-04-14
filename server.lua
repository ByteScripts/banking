local bank = require 'modules.bank.server'

Cache = {
    data = {},
    update = function(value)
        Cache.data = value
        TriggerClientEvent('bank:updateCache', -1, Cache.data)
    end,
    updateSingle = function(key, value)
        Cache.data[key] = value
        TriggerClientEvent('bank:updateCache', -1, Cache.data)
    end
}

lib.callback.register('bank:openBankAccount', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.openBankAccount(xPlayer)
end)

lib.callback.register('bank:setPin', function(_, item, pin)
    return bank.setPin(item, pin)
end)

lib.callback.register('bank:withdraw', function(src, item, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.withdraw(xPlayer, item, amount)
end)

lib.callback.register('bank:deposit', function(src, item, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.deposit(xPlayer, item, amount)
end)

lib.callback.register('bank:closeAccount', function(src, item)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.closeAccount(xPlayer, item)
end)

lib.callback.register('bank:transfer', function(src, item, iban, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.transfer(xPlayer, item, iban, amount)
end)

RegisterNetEvent('esx:playerLoaded', function(src)
    TriggerClientEvent('bank:updateCache', src, Cache.data)
end)

exports('AddTransaction', bank.addTransaction)
require 'modules.commands.server'