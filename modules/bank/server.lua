local bank = {}

bank.openBankAccount = function(xPlayer)
    local hasCreditCard = exports.ox_inventory:GetItemCount(xPlayer.source, Config.item) > 0
    if hasCreditCard then return false, locale('general.errors.already_have_account') end

    local currentDate = os.date('*t')
    local expireDate = Server.date.add(currentDate, 1)
    local twentyTwoDigits = string.format('%s%s', math.random(10000000000, 99999999999), math.random(10000000000, 99999999999))
    local metadata = {
        owner = xPlayer.identifier,
        name = xPlayer.name,
        description = string.format('%s: %s   \n   %s: %s/%s', locale('holder'), xPlayer.name, locale('expires'), expireDate.month, expireDate.year),
        iban = string.format('DE%s',twentyTwoDigits),
        balance = 0,
        number = math.random(1000000000000000, 9999999999999999),
        cvv = math.random(100, 999),
        expires = {
            string = string.format('%s/%s', expireDate.month, expireDate.year),
            date = expireDate
        },
        transactions = {},
        pin = nil,
    }
    local success, response = exports.ox_inventory:AddItem(xPlayer.source, Config.item, 1, metadata)

    return success, response
end

bank.setPin = function(xPlayer, item, pin)
    if not item or not pin then return false, locale('general.errors.invalid_params') end

    local newMetadata = item.metadata

    newMetadata.pin = pin
    exports.ox_inventory:SetMetadata(xPlayer.source, item.slot, newMetadata)

    return true
end

bank.withdraw = function(xPlayer, item, amount)
    if not item or not amount then
        return false, locale('general.errors.invalid_params')
    end

    local newMetadata = item.metadata
    if newMetadata.balance < amount then
        return false, locale('general.errors.insufficient_funds')
    end

    newMetadata.balance = newMetadata.balance - amount
    exports.ox_inventory:SetMetadata(xPlayer.source, item.slot, newMetadata)
    bank.addTransaction(xPlayer, item, amount, 'withdraw')
    xPlayer.addMoney(amount)

    return true
end

bank.deposit = function(xPlayer, item, amount)
    if not item or not amount then
        return false, locale('general.errors.invalid_params')
    end
    if xPlayer.getMoney() < amount then
        return false, locale('general.errors.insufficient_funds')
    end

    local newMetadata = item.metadata

    newMetadata.balance = newMetadata.balance + amount
    exports.ox_inventory:SetMetadata(xPlayer.source, item.slot, newMetadata)
    bank.addTransaction(xPlayer, item, amount, 'deposit')
    xPlayer.removeMoney(amount)

    return true
end

bank.addTransaction = function(xPlayer, item, amount, type)
    if not item or not amount or not type then
        return false, locale('general.errors.invalid_params')
    end

    local newMetadata = item.metadata
    table.insert(newMetadata.transactions, {
        amount = amount,
        type = type,
        date = os.date('*t'),
        from = {
            name = xPlayer.name,
            identifier = xPlayer.identifier
        }
    })
    exports.ox_inventory:SetMetadata(xPlayer.source, item.slot, newMetadata)

    return true
end

bank.closeAccount = function(xPlayer, item)
    if not item then return false, locale('general.errors.invalid_params') end

    local success, response = exports.ox_inventory:RemoveItem(xPlayer.source, item.name, 1, item.metadata, item.slot)
    if not success then return false, response end

    return true
end

return bank