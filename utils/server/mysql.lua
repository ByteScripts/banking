local db = {}
local databaseMeta = {
    __index = function(tbl, key)
        local tableDef = db[key]
        if tableDef then
            return {
                create = function(object)
                    local data = object.data
                    local columns = {}

                    for columnName, columnType in pairs(tableDef) do
                        if data[columnName] then
                            table.insert(columns, columnName)
                        end
                    end

                    local query = "INSERT INTO " .. key .. " (" .. table.concat(columns, ', ') .. ") VALUES ("
                    for _, columnName in ipairs(columns) do
                        query = query .. "'" .. data[columnName] .. "', "
                    end

                    query = query:sub(1, -3) .. ")"
                    MySQL.query.await(query)
                end,
                createMany = function(objects)
                    for _, object in ipairs(objects) do
                        tbl.create(object)
                    end
                end,
                delete = function(object)
                    local where = object.where
                    local query = "DELETE FROM " .. key .. " WHERE "
                    for columnName, value in pairs(where) do
                        query = query .. columnName .. " = '" .. value .. "' AND "
                    end

                    query = query:sub(1, -5)
                    MySQL.query.await(query)

                    return object
                end,
                deleteMany = function(objects)
                    for _, object in ipairs(objects) do
                        tbl.delete(object)
                    end
                end,
                findFirst = function(object)
                    local where = object.where
                    local query = "SELECT * FROM " .. key .. " WHERE "
                    for columnName, value in pairs(where) do
                        query = query .. columnName .. " = '" .. value .. "' AND "
                    end

                    query = query:sub(1, -5)
                    local result = MySQL.query.await(query)
                    return result[1]
                end,
                findMany = function(object)
                    local where = object.where
                    local query = "SELECT * FROM " .. key .. " WHERE "
                    for columnName, value in pairs(where) do
                        query = query .. columnName .. " = '" .. value .. "' AND "
                    end

                    query = query:sub(1, -5)
                    return MySQL.query.await(query)
                end,
                findUnique = function(object)
                    local where = object.where
                    local query = "SELECT * FROM " .. key .. " WHERE "
                    for columnName, value in pairs(where) do
                        query = query .. columnName .. " = '" .. value .. "' AND "
                    end

                    query = query:sub(1, -5)
                    local result = MySQL.query.await(query)
                    return result[1]
                end,
                update = function(object)
                    local data, where = object.data, object.where
                    local query = "UPDATE " .. key .. " SET "
                    for columnName, value in pairs(data) do
                        query = query .. columnName .. " = '" .. value .. "', "
                    end

                    query = query:sub(1, -3) .. " WHERE "
                    for columnName, value in pairs(where) do
                        query = query .. columnName .. " = '" .. value .. "' AND "
                    end

                    query = query:sub(1, -5)
                    MySQL.query.await(query)
                    return object
                end,
                updateMany = function(objects)
                    for _, object in ipairs(objects) do
                        tbl.update(object)
                    end

                    return objects
                end,
                getAll = function()
                    return MySQL.query.await("SELECT * FROM " .. key)
                end,
            }
        else
            error("Table '" .. key .. "' not found in database. May need to add it to the db object in server/db/index.lua.")
        end
    end,
}

local function columnExists(tableName, columnName)
    local result = MySQL.query.await("SHOW COLUMNS FROM " .. tableName .. " LIKE '" .. columnName .. "'")
    return #result > 0
end

local function synchronizeColumns(tableName, tableDef)
    local existingColumns = MySQL.query.await("SHOW COLUMNS FROM " .. tableName)
    local definedColumns = {}
    for columnName, columnType in pairs(tableDef) do
        definedColumns[columnName] = true
    end

    local columnsAdded = false

    for _, existingColumn in ipairs(existingColumns) do
        local columnName = existingColumn.Field
        if not definedColumns[columnName] then
            MySQL.query.await("ALTER TABLE " .. tableName .. " DROP COLUMN " .. columnName)
        end
    end

    for columnName, columnType in pairs(tableDef) do
        if not columnExists(tableName, columnName) then
            MySQL.query.await("ALTER TABLE " .. tableName .. " ADD " .. columnName .. " " .. columnType)
            columnsAdded = true
        end
    end

    if columnsAdded then
        MySQL.query.await("SHOW TABLES")
    end
end

local function createTables()
    for tableName, tableDef in pairs(db) do
        local tableExists = MySQL.query.await("SHOW TABLES LIKE '" .. tableName .. "'")
        if #tableExists == 0 then
            local query = "CREATE TABLE " .. tableName .. " ("
            for columnName, columnType in pairs(tableDef) do
                query = query .. columnName .. " " .. columnType .. ", "
            end
            query = query:sub(1, -3) .. ")"
            MySQL.query.await(query)
        else
            synchronizeColumns(tableName, tableDef)
        end
    end
end

Database = {}
setmetatable(Database, databaseMeta)

shared.onResourceStart(function()
    createTables()
end)