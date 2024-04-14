local bank = require 'modules.bank.client'
local atms = lib.load('data.atms')
local atmsJson = lib.loadJson('data.atms_locations')

local function registerPoint(coords)
    lib.points.new({
        coords = coords,
        distance = 1.5,
        onEnter = function()
            if Shared.textUi then Config.textUi.show(locale('press_to_open')) end
        end,
        nearby = function()
            if not Shared.textUi then Config.helpNotification(locale('press_to_open')) end

            if IsControlJustPressed(0, 38) then
                bank.open()
            end
        end,
        onExit = function()
            if Shared.textUi then Config.textUi.hide() end
        end,
    })
end

Cache = {}

RegisterNetEvent('bank:updateCache', function(cache)
    Cache = cache
end)

CreateThread(function()
    for _, bankData in pairs(lib.load('data.banks')) do
        local blip = bankData.blip
        if blip then
            Client.createBlip(bankData.label, bankData.coords.xyz, blip.id, blip.colour, blip.scale, true)
        end

        local target = bankData.target
        if target then
            local entity = Client.createPed(target.model, bankData.coords, target.animation)
            if not entity then goto create_point end

            if Shared.target then
                exports.ox_target:addLocalEntity(entity, {
                    name = 'banking:openBank',
                    label = locale('open'),
                    icon = 'fas fa-university',
                    onSelect = function()
                        return bank.open()
                    end
                })
            else
                goto create_point
            end
        end

        if Shared.target and not target then
            exports.ox_target:addBoxZone({
                size = target.size,
                coords = bankData.coords,
                options= {
                    {
                        name = 'banking:openBank',
                        label = locale('open'),
                        icon = 'fas fa-university',
                        onSelect = function()
                            return bank.open()
                        end
                    }
                }
            })
        else
            goto create_point
        end

        ::create_point::
        if not Shared.target then registerPoint(bankData.coords) end
    end

    if Shared.target then
        exports.ox_target:addModel(atms, {
            {
                icon = 'fas fa-credit-card',
                name = 'banking:openAtm',
                label = locale('open_atm'),
                onSelect = function()
                    return bank.open(true)
                end,
                distance = 1.5
            }
        })
    else
        for _, value in pairs(atmsJson) do
            local coords = vec3(value.Position.X, value.Position.Y, value.Position.Z)
            registerPoint(coords)
        end
    end

    if Config.atmBlips then
        for _, value in pairs(atmsJson) do
            local coords = vec3(value.Position.X, value.Position.Y, value.Position.Z)
            Client.createBlip('ATM', coords, 277, 2, 0.5, true)
        end
    end
end)