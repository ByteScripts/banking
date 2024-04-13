local bank = require 'modules.bank.client'

CreateThread(function()
    for _, bankData in pairs(lib.load('data.banks')) do
        local blip = bankData.blip
        if blip then
            Client.createBlip(bankData.label, bankData.coords.xyz, blip.id, blip.colour, blip.scale, true)
        end

        local target = bankData.target
        if target then
            local entity = Client.createPed(target.model, bankData.coords, target.animation)
            if not entity then goto skip end

            exports.ox_target:addLocalEntity(entity, {
                name = 'banking:openBank',
                label = locale('open'),
                icon = 'fas fa-university',
                onSelect = function()
                    return bank.open()
                end
            })

            goto skip
        end

        exports.ox_target:addBoxZone({
            size = target.size,
            coords = target.coords,
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
        ::skip::
    end
end)