--- @param name string
--- @param location vector3
--- @param sprite number
--- @param color number
--- @param scale number
--- @param shortRange boolean
--- @return number
function Client.createBlip(name, location, sprite, color, scale, shortRange)
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
function Client.removeBlips(blips)
    for _, value in pairs(blips) do
        RemoveBlip(value)
    end
end

--- @param model any
--- @param location vector4
--- @param animation { scenario: string }|{ dict: string, anim: string, flag: number }|nil
--- @return number?
function Client.createPed(model, location, animation)
    model = lib.requestModel(model)
    if not model then return end

    local entity = CreatePed(0, model, location.x, location.y, location.z, location.w, false, true)
    if animation and animation.scenario then
        TaskStartScenarioInPlace(entity, animation.scenario, 0, true)
    elseif animation and animation.dict then
        lib.requestAnimDict(animation.dict)
        TaskPlayAnim(entity, animation.dict, animation.anim, 8.0, 0.0, -1, animation.flag, 0, false, false, false)
    end

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    return entity
end

--- @param model any
--- @param location vector4
--- @return number?
function Client.createObject(model, location)
    model = lib.requestModel(model)
    if not model then return end

    local object = CreateObject(model, location.x, location.y, location.z, true, true, true)

    SetEntityHeading(object, location.w)
    SetEntityAsMissionEntity(object, true, true)
    SetEntityInvincible(object, true)
    FreezeEntityPosition(object, true)

    return object
end

--- @param peds number[]
function Client.removePeds(peds)
    for _, value in pairs(peds) do
        DeleteEntity(value)
        exports.ox_target:removeLocalEntity(value)
    end
end

--- @param objects number[]
function Client.removeObjects(objects)
    for _, value in pairs(objects) do
        DeleteEntity(value)
        DeleteObject(value)
        exports.ox_target:removeLocalEntity(value)
    end
end

--- @param location vector3
--- @param size vector3
--- @param color ColorTable
function Client.drawMarker(location, size, color)
    ---@diagnostic disable-next-line: param-type-mismatch
    DrawMarker(1, location.x, location.y, location.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size.x, size.y, size.z, color.r, color.g, color.b, color.a, false, false, 2, false, false, false, false)
end