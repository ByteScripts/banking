local bank = {}

bank.openBankAccount = function(xPlayer, forceCreate)
    local hasCreditCard = exports.ox_inventory:GetItemCount(xPlayer.source, Config.item) > 0
    if hasCreditCard and not forceCreate then return false, locale('general.errors.already_have_account') end

    local currentDate = os.date('*t')
    local expireDate = Server.date.add(currentDate, 1)
    local twentyTwoDigits = string.format('%s%s', math.random(10000000000, 99999999999), math.random(10000000000, 99999999999))
    local metadata = {
        owner = xPlayer.identifier,
        description = string.format('%s: %s   \n   %s: %s/%s', locale('holder'), xPlayer.name, locale('expires'), expireDate.month, expireDate.year),
        iban = string.format('DE%s',twentyTwoDigits)
    }
    local success, response = exports.ox_inventory:AddItem(xPlayer.source, Config.item, 1, metadata)
    local data = {
        identifier = xPlayer.identifier,
        name = xPlayer.name,
        iban = metadata.iban,
        balance = 0,
        number = math.random(1000000000000000, 9999999999999999),
        cvv = math.random(100, 999),
        expires = json.encode({
            string = string.format('%s/%s', expireDate.month, expireDate.year),
            date = expireDate
        }),
    }

    Database.credit_cards.create({
        data = data
    })
    Cache.updateSingle(data.iban, data)
    return success, response
end

bank.setPin = function(item, pin)
    if not item or not pin then return false, locale('general.errors.invalid_params') end

    item.metadata.pin = pin
    Database.credit_cards.update({
        data = {
            pin = pin
        },
        where = {
            iban = item.metadata.iban
        }
    })
    Cache.updateSingle(item.metadata.iban, item.metadata)

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
    bank.addTransaction(xPlayer, item, amount, 'withdraw')
    xPlayer.addMoney(amount)
    Database.credit_cards.update({
        data = {
            balance = newMetadata.balance
        },
        where = {
            iban = newMetadata.iban
        }
    })
    Cache.updateSingle(newMetadata.iban, newMetadata)

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
    bank.addTransaction(xPlayer, item, amount, 'deposit')
    xPlayer.removeMoney(amount)
    Database.credit_cards.update({
        data = {
            balance = newMetadata.balance
        },
        where = {
            iban = newMetadata.iban
        }
    })
    Cache.updateSingle(newMetadata.iban, newMetadata)

    return true
end

bank.addTransaction = function(xPlayer, item, amount, transactionType)
    if not item or not amount or not transactionType then
        return false, locale('general.errors.invalid_params')
    end

    local newMetadata = item.metadata
    if not newMetadata.transactions then newMetadata.transactions = {} end

    newMetadata.transactions = type(newMetadata.transactions) == 'table' and newMetadata.transactions or json.decode(newMetadata.transactions)

    table.insert(newMetadata.transactions, {
        amount = amount,
        type = transactionType,
        date = os.date('*t'),
        from = {
            name = xPlayer.name,
            identifier = xPlayer.identifier
        }
    })
    Database.credit_cards.update({
        data = {
            transactions = json.encode(newMetadata.transactions)
        },
        where = {
            iban = newMetadata.iban
        }
    })
    Cache.updateSingle(newMetadata.iban, newMetadata)

    return true
end

bank.closeAccount = function(xPlayer, item)
    if not item then return false, locale('general.errors.invalid_params') end

    local success, response = exports.ox_inventory:RemoveItem(xPlayer.source, Config.item, 1, nil, item.slot)
    if not success then return false, response end

    Database.credit_cards.delete({
        where = {
            iban = item.metadata.iban
        }
    })
    return true
end

bank.transfer = function(xPlayer, item, iban, amount)
    if not item or not iban or not amount then
        return false, locale('general.errors.invalid_params')
    end

    local account = Database.credit_cards.findFirst({
        where = {
            iban = iban
        }
    })
    if not account then return false, locale('transfer.errors.invalid_iban') end

    local newMetadata = item.metadata
    if newMetadata.balance < amount then
        return false, locale('general.errors.insufficient_funds')
    end

    newMetadata.balance = newMetadata.balance - amount
    account.balance = account.balance + amount
    bank.addTransaction(xPlayer, item, amount, 'transfer')
    Database.credit_cards.update({
        data = {
            balance = newMetadata.balance
        },
        where = {
            iban = newMetadata.iban
        }
    })
    Database.credit_cards.update({
        data = {
            balance = account.balance
        },
        where = {
            iban = iban
        }
    })
    Cache.updateSingle(newMetadata.iban, newMetadata)
    Cache.updateSingle(iban, account)

    local xTarget = ESX.GetPlayerFromIdentifier(account.identifier)
    if xTarget then
        Config.notify(locale('transfer.target_message', amount, xPlayer.name), 'info', xTarget.source)
    end

    return true
end

return bank