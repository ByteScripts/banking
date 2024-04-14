local bank = {}
local menu = require 'modules.menu.client'

bank.open = function(isAtm)
    local hasCreditCard = exports.ox_inventory:GetItemCount(Config.item) > 0
    if not hasCreditCard then return menu.noCreditCard.open() end

    local creditCardItems = exports.ox_inventory:Search('slots', Config.item)
    if not creditCardItems or #creditCardItems <= 0 then return menu.noCreditCard.open() end

    local data = Shared.table.map(creditCardItems, function(value)
        local data = Cache[value.metadata.iban]
        if not data then return end

        local item = {
            metadata = data,
            slot = value.slot
        }
        return {
            icon = 'fas fa-credit-card',
            title = string.format('%s (%s)', locale('credit_card'), item.metadata.name),
            description = string.format('%s: $%s', locale('balance'), item.metadata.balance),
            onSelect = function()
                if not item.metadata.pin then return bank.pin.create(item) end

                local success = bank.pin.check(item)
                if not success then return end

                return menu.creditCard.open(bank, item, isAtm)
            end
        }
    end)

    lib.registerContext({
        id = 'bank:main',
        title = locale('title'),
        options = data,
    })

    lib.showContext('bank:main')
end

bank.pin = {
    create = function(item)
        local promptSuccess, response = Client.promptDialog(locale('title'), locale('pin.set'), function(pin)
            if not pin then
                Config.notify(locale('pin.errors.not_entered'), 'error')
                return false
            end

            local length = string.len(pin)
            if length ~= 4 then
                Config.notify(locale('pin.errors.invalid'), 'error')
                return false
            end

            return true, pin
        end)
        if not promptSuccess or not response then return bank.pin.create() end

        local success, err = lib.callback.await('bank:setPin', false, item, response)
        if not success then return Config.notify(err, 'error') end

        Config.notify(locale('pin.success'), 'success')
        return true
    end,
    check = function(item)
        local success, response = Client.promptDialog(locale('title'), locale('pin.enter'), function(pin)
            if not pin then
                Config.notify(locale('pin.errors.not_entered'), 'error')
                return false
            end

            local length = string.len(pin)
            if length ~= 4 then
                Config.notify(locale('pin.errors.invalid'), 'error')
                return false
            end

            return true, pin
        end)

        if not success and response then
            Config.notify(response, 'error')
            return
        elseif not success then
            return bank.open()
        end
        if not response then return end

        if tonumber(response) ~= tonumber(item.metadata.pin) then
            bank.open()
            return Config.notify(locale('pin.errors.incorrect'), 'error')
        end

        return true
    end
}

bank.actions = {
    withdraw = function(item)
        local success, response = Client.promptDialog(locale('title'), locale('withdraw.description'), function(amount)
            if not amount then
                Config.notify(locale('general.errors.not_entered_amount'), 'error')
                return false
            end

            local newAmount = tonumber(amount)
            if not newAmount or newAmount <= 0 then
                Config.notify(locale('general.errors.invalid_amount'), 'error')
                return false
            end

            return true, newAmount
        end)
        if not success or not response then return end

        if item.metadata.balance < response then
            return Config.notify(locale('withdraw.errors.insufficient_funds'), 'error')
        end

        local withdrawSuccess, withdrawResponse = lib.callback.await('bank:withdraw', false, item, response)
        if not withdrawSuccess then return Config.notify(withdrawResponse, 'error') end

        Config.notify(locale('withdraw.success', response), 'success')
    end,
    deposit = function(item)
        local success, response = Client.promptDialog(locale('title'), locale('deposit.description'), function(amount)
            if not amount then
                Config.notify(locale('general.errors.not_entered_amount'), 'error')
                return false
            end

            local newAmount = tonumber(amount)
            if not newAmount or newAmount <= 0 then
                Config.notify(locale('general.errors.invalid_amount'), 'error')
                return false
            end

            return true, newAmount
        end)
        if not success or not response then return end

        local depositSuccess, depositResponse = lib.callback.await('bank:deposit', false, item, response)
        if not depositSuccess then return Config.notify(depositResponse, 'error') end

        Config.notify(locale('deposit.success', response), 'success')
    end,
    changePin = function(item)
        local promptSuccess, promptResponse = Client.promptDialog(locale('title'), locale('menu.change_pin.title'), function(newPin)
            if not newPin then
                Config.notify(locale('pin.errors.not_entered'), 'error')
                return false
            end

            local length = string.len(newPin)
            if length ~= 4 then
                Config.notify(locale('pin.errors.invalid'), 'error')
                return false
            end

            return true, newPin
        end)
        if not promptSuccess or not promptResponse then return menu.creditCard.open(bank, item) end

        local success, response = lib.callback.await('bank:setPin', false, item, promptResponse)
        if not success then return Config.notify(response, 'error') end

        Config.notify(locale('pin.changed'), 'success')
    end,
    closeAccount = function(item)
        Client.alertDialog(locale('title'), locale('close.description'), function()
            local isOwner = item.metadata.identifier == ESX.PlayerData.identifier
            if not isOwner then return Config.notify(locale('close.errors.not_owner'), 'error') end

            local success, err = lib.callback.await('bank:closeAccount', false, item)
            if not success then return Config.notify(err, 'error') end

            return Config.notify(locale('close.success'), 'success')
        end)
    end,
    transfer = function(item)
        local response = lib.inputDialog(locale('title'), {
            {
                label = locale('menu.iban.title'),
                description = locale('transfer.iban_placeholder'),
                type = 'input',
                required = true,
            },
            {
                label = locale('menu.transfer.title'),
                description = locale('transfer.amount_placeholder'),
                type = 'number',
                required = true,
            }
        })
        if not response or not response[1] or not response[2] then return end

        local iban, amount = response[1], tonumber(response[2])
        if not iban or not amount or amount <= 0 then
            return Config.notify(locale('transfer.errors.invalid_fields'), 'error')
        end

        local success, err = lib.callback.await('bank:transfer', false, item, iban, amount)
        if not success then return Config.notify(err, 'error') end

        Config.notify(locale('transfer.success', amount, iban), 'success')
    end
}

return bank