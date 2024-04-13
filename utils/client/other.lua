--- @param name string
--- @param location vector3
--- @param sprite number
--- @param color number
--- @param scale number
--- @param shortRange boolean
--- @return number
function client.createBlip(name, location, sprite, color, scale, shortRange)
    local blip = AddBlipForCoord(location.x, location.y, location.z)

    SetBlipSprite(blip, sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale or 0.8)
    SetBlipColour(blip, color or 1)
    SetBlipAsShortRange(blip, shortRange or true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)

    return blip
end

--- @param blips number[]
function client.removeBlips(blips)
    for _, value in pairs(blips) do
        RemoveBlip(value)
    end
end

--- @param model any
--- @param location vector4
--- @return number
function client.createPed(model, location)
    model = GetHashKey(model)
    lib.requestModel(model)

    local ped = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.w, false, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    return ped
end

--- @param model any
--- @param location vector4
--- @return number
function client.createObject(model, location)
    model = GetHashKey(model)
    lib.requestModel(model)

    local object = CreateObject(model, location.x, location.y, location.z, true, true, true)

    SetEntityHeading(object, location.w)
    SetEntityAsMissionEntity(object, true, true)
    SetEntityInvincible(object, true)
    FreezeEntityPosition(object, true)

    return object
end

--- @param peds number[]
function client.removePeds(peds)
    for _, value in pairs(peds) do
        DeleteEntity(value)
        exports.ox_target:removeLocalEntity(value)
    end
end

--- @param objects number[]
function client.removeObjects(objects)
    for _, value in pairs(objects) do
        DeleteEntity(value)
        DeleteObject(value)
        exports.ox_target:removeLocalEntity(value)
    end
end

--- @param location vector3
--- @param size vector3
--- @param color ColorTable
function client.drawMarker(location, size, color)
    ---@diagnostic disable-next-line: param-type-mismatch
    DrawMarker(1, location.x, location.y, location.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size.x, size.y, size.z, color.r, color.g, color.b, color.a, false, false, 2, false, false, false, false)
end