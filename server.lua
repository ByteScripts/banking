local bank = require 'modules.bank.server'

lib.callback.register('bank:openBankAccount', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.openBankAccount(xPlayer)
end)

lib.callback.register('bank:setPin', function(src, item, pin)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.setPin(xPlayer, item, pin)
end)

lib.callback.register('bank:withdraw', function(src, item, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.withdraw(xPlayer, item, amount)
end)

lib.callback.register('bank:deposit', function(src, item, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    return bank.deposit(xPlayer, item, amount)
end)

exports('AddTransaction', bank.addTransaction)