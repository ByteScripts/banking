--- @param header string
--- @param content string
--- @param callback function
function Client.alertDialog(header, content, callback)
    local alertAnswer = lib.alertDialog({
        header = header,
        content = content,
        centered = true,
        cancel = true
    })
    if alertAnswer == 'confirm' then callback() end
end

--- @param title string
--- @param description string
--- @param check fun(value: string): boolean, any?
--- @return boolean, any?
function Client.promptDialog(title, description, check)
    local input = lib.inputDialog(title, {
        { type = 'input' , label = description, required = true},
    })
    if not input then return false, 'Please enter something in' end

    local value = input[1]
    local success, response = check(tostring(value))
    if not success then return false, response end
    return true, response
end

--- @return number?
function Client.amountInput()
    local input = lib.inputDialog('Amount', {
        { type = 'input' , label = 'Amount', description = 'Enter your amount', required = true},
    })
    if not input then return 0 end
    return tonumber(input[1])
end

--- @param title string
--- @param label string
--- @param description string
--- @param default string
--- @return any
function Client.textInput(title, label, description, default)
    local input = lib.inputDialog(title, {
        { type = 'input' , label = label, description = description, default = default, required = true},
    })
    if not input then return false end
    return input[1]
end

--- @param title string
--- @param message string
--- @param type NotificationType
function Client.notify(title, message, type)
    --- @type NotifyProps
    local data = {
        title = title,
        description = message,
        type = type or 'info',
    }

    lib.notify(data)
end

--- @param points CPoint[]
function Client.removePoints(points)
    for _, value in pairs(points) do
        value:remove()
    end
end