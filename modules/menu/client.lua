local menu = {}

menu.noCreditCard = {
    open = function()
        return Client.alertDialog(locale('title'), locale('create.description'), function()
            local success, err = lib.callback.await('bank:openBankAccount', false)
            if not success then return Config.notify(err, 'error') end

            return Config.notify(locale('create.success'), 'success')
        end)
    end
}

menu.creditCard = {
    open = function(bank, item, isAtm)
        isAtm = isAtm or false

        local function reopen(object)
            if object then
                Config.notify(object[1], object[2])
            end

            return menu.creditCard.open(bank, item)
        end

        local options = {
            {
                name = 'balance',
                icon = 'fas fa-dollar-sign',
                title = locale('balance'),
                description = string.format('$%s', item.metadata.balance),
            },
            {
                name = 'main_card',
                icon = 'fas fa-star',
                title = locale('menu.main_card.title'),
                description = locale('menu.main_card.description'),
                disabled = item.metadata.main,
                onSelect = function()
                    bank.actions.setMainCard(item)
                end,
            },
            {
                name = 'iban',
                icon = 'fas fa-credit-card',
                title = locale('menu.iban.title'),
                description = locale('menu.iban.description', item.metadata.iban),
                onSelect = function()
                    lib.setClipboard(item.metadata.iban)
                    reopen({
                        locale('iban.copied'),
                        'success'
                    })
                end
            },
            {
                name = 'withdraw',
                icon = 'fas fa-money-bill-wave',
                title = locale('withdraw.title'),
                description = locale('withdraw.description'),
                onSelect = function()
                    bank.actions.withdraw(item)
                end
            },
            {
                name = 'deposit',
                icon = 'fas fa-money-bill-wave',
                title = locale('deposit.title'),
                description = locale('deposit.description'),
                onSelect = function()
                    bank.actions.deposit(item)
                end
            },
            {
                name = 'transfer',
                icon = 'fas fa-exchange-alt',
                title = locale('menu.transfer.title'),
                description = locale('menu.transfer.description'),
                onSelect = function()
                    bank.actions.transfer(item)
                end
            },
            {
                name = 'transactions',
                icon = 'fas fa-history',
                title = locale('menu.transactions.title'),
                description = locale('menu.transactions.description'),
                onSelect = function()
                    if #item.metadata.transactions == 0 then
                        return reopen({
                            locale('menu.transactions.error'),
                            'error'
                        })
                    end

                    return menu.transactions.open(item.metadata.transactions)
                end
            },
            {
                name = 'change_pin',
                icon = 'fas fa-key',
                title = locale('menu.change_pin.title'),
                description = locale('menu.change_pin.description'),
                onSelect = function()
                    return bank.actions.changePin(item)
                end
            },
            {
                name = 'close_account',
                icon = 'fas fa-trash',
                title = locale('menu.close_account.title'),
                description = locale('menu.close_account.description'),
                onSelect = function()
                    return bank.actions.closeAccount(item)
                end
            },
        }

        lib.registerContext({
            id = 'bank:creditcard',
            menu = 'bank:main',
            title = string.format('%s (%s)', locale('credit_card'), item.metadata.name),
            options = not isAtm and options or Shared.table.filter(options, function(option)
                return Config.atmOptions[option.name]
            end)
        })

        lib.showContext('bank:creditcard')
    end
}

menu.transactions = {
    open = function(transactions)
        local options = Shared.table.map(transactions, function(transaction)
            local date = string.format('%s.%s.%s %s:%s', transaction.date.day, transaction.date.month, transaction.date.year, transaction.date.hour, transaction.date.min)
            local title = transaction.type == 'withdraw' and locale('withdraw.title') or locale('deposit.title')
            return {
                icon = 'fas fa-money-bill-wave',
                title = title,
                description = string.format('$%s - %s', transaction.amount, date),
            }
        end)

        lib.registerContext({
            id = 'bank:transactions',
            menu = 'bank:creditcard',
            title = 'Transactions',
            options = options,
        })

        lib.showContext('bank:transactions')
    end
}

return menu