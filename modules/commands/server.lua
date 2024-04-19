local bank = require 'modules.bank.server'

lib.addCommand('bank:menu', {
    restricted = Config.restricted
}, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    TriggerClientEvent('bank:openAdminMenu', src)
end)

lib.addCommand('bank:giveCreditCard', {
    params = {
        {
            name = 'id',
            help = 'Player ID',
            optional = true,
            type = 'playerId'
        }
    },
    restricted = Config.restricted
}, function(src, args)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local target = args.id and ESX.GetPlayerFromId(args.id) or xPlayer
    if not target then return Config.notify(locale('command.not_online'), 'error', src) end

    bank.openBankAccount(target, true)
    Config.notify(locale('command.give_credit_card', target.name), 'info', src)
end)

lib.addCommand('bank:setMoney', {
    params = {
        {
            name = 'iban',
            help = 'IBAN',
            type = 'string'
        },
        {
            name = 'amount',
            help = 'Amount',
            type = 'number'
        }
    },
    restricted = Config.restricted
}, function(src, args)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local account = Cache.data[args.iban]
    if not account then return Config.notify(locale('command.invalid_iban'), 'error', src) end

    account.balance = args.amount
    Database.credit_cards.update({
        data = {
            balance = args.amount
        },
        where = {
            iban = args.iban
        }
    })
    Cache.updateSingle(args.iban, account)
    Config.notify(locale('command.set_money', args.amount, args.iban), 'info', src)

    local xTarget = ESX.GetPlayerFromIdentifier(account.identifier)
    if xTarget then
        Config.notify(locale('command.set_money_target', args.amount, xPlayer.name), 'info', xTarget.source)
    end
end)