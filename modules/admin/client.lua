local function openSingleMenu(data)
    --- @type ContextMenuArrayItem[]|{ [string]: ContextMenuItem } { [string]: ContextMenuItem, }
    local options = {
        {
            title = locale('admin_menu.single.balance.title'),
            description = Shared.formatPrice(data.balance),
            icon = 'fas fa-wallet'
        },
        {
            title = locale('admin_menu.single.iban.title'),
            description = data.iban,
            icon = 'fas fa-credit-card',
            onSelect = function()
                lib.setClipboard(data.iban)
                Config.notify(locale('admin_menu.single.copied_to_clipboard'), 'success')
            end,
        },
        {
            title = locale('admin_menu.single.holder.title'),
            description = data.name,
            icon = 'fas fa-user',
            onSelect = function()
                lib.setClipboard(data.name)
                Config.notify(locale('admin_menu.single.copied_to_clipboard'), 'success')
            end,
        },
        {
            title = locale('admin_menu.single.resend.title'),
            description = locale('admin_menu.single.resend.description'),
            icon = 'fas fa-paper-plane',
            onSelect = function()
                Client.alertDialog(locale('admin_menu.single.resend.title'), locale('admin_menu.single.resend.are_you_sure'), function()
                    local success, err = lib.callback.await('bank:resendCard', false, data.iban, data.identifier)
                    if not success then return Config.notify(err, 'error') end

                    return Config.notify(locale('admin_menu.single.resend.success'), 'success')
                end)
            end,
        }
    }

    lib.registerContext({
        id = 'bank:admin:single',
        title = locale('admin_menu.single.title'),
        menu = 'bank:admin:list',
        options = options
    })

    lib.showContext('bank:admin:single')
end

local function openSearchMenu()
    local response = lib.inputDialog(locale('admin_menu.list.search.title'), {
        {
            label = locale('admin_menu.list.search.title'),
            description = locale('admin_menu.list.search.description'),
            type = 'select',
            options = {
                {
                    label = locale('admin_menu.list.search.iban'),
                    value = 'iban'
                },
                {
                    label = locale('admin_menu.list.search.identifier'),
                    value = 'identifier'
                }
            },
            required = true
        },
        {
            label = locale('admin_menu.list.search.value.title'),
            description = locale('admin_menu.list.search.value.description'),
            type = 'input',
            required = true
        }
    })
    if not response then return end

    local key, value = response[1], response[2]
    local finalValue = key == 'iban' and tonumber(value) or value
    local card = Shared.table.find(Cache, key, finalValue)
    if not card then return Config.notify(locale('admin_menu.list.search.not_found', tostring(finalValue)), 'error') end

    return openSingleMenu(card)
end

local function openListMenu()
    --- @type ContextMenuArrayItem[]|{ [string]: ContextMenuItem } { [string]: ContextMenuItem, }
    local options = {
        {
            title = locale('admin_menu.list.search.title'),
            description = locale('admin_menu.list.search.description'),
            icon = 'fas fa-search',
            onSelect = openSearchMenu
        }
    }

    Shared.table.map(Cache, function(value)
        table.insert(options, {
            title = ('%s (%s)'):format(value.name, value.iban),
            description = Shared.formatPrice(value.balance),
            icon = 'fas fa-credit-card',
            onSelect = function()
                openSingleMenu(value)
            end
        })
    end)

    lib.registerContext({
        id = 'bank:admin:list',
        title = locale('admin_menu.list.title'),
        menu = 'bank:admin',
        options = options
    })

    lib.showContext('bank:admin:list')
end

local function openAdminMenu()
    lib.registerContext({
        id = 'bank:admin',
        title = locale('admin_menu.title'),
        options = {
            {
                 title = locale('admin_menu.give_credit_card.title'),
                 description = locale('admin_menu.give_credit_card.description'),
                 icon = 'fas fa-credit-card',
                 onSelect = function()
                    local response = lib.inputDialog(locale('admin_menu.give_credit_card.title'), {
                        {
                            label = locale('admin_menu.give_credit_card.player.title'),
                            description = locale('admin_menu.give_credit_card.description'),
                            type = 'number',
                            required = true
                        }
                    })
                    if not response then return end

                    local src = tonumber(response[1])
                    if not src then return end

                    local success, err = lib.callback.await('bank:openBankAccount', false, src)
                    if not success then return Config.notify(err, 'error') end

                    Config.notify(locale('admin_menu.give_credit_card.success', src), 'success')
                 end,
            },
            {
                title = locale('admin_menu.list.title'),
                description = locale('admin_menu.list.description'),
                icon = 'fas fa-list',
                onSelect = openListMenu
            }
        }
    })

    lib.showContext('bank:admin')
end

RegisterNetEvent('bank:openAdminMenu', function(src)
    openAdminMenu()
end)