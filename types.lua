--- @class ColorTable
--- @field r number
--- @field g number
--- @field b number
--- @field a number

---@class MySQLCreate
---@field data table

---@class MySQLDelete
---@field where table

---@class MySQLFind
---@field where table

---@class MySQLUpdate
---@field data table
---@field where table

---@class TableMeta
---@field getAll fun()
---@field create fun(object: MySQLCreate)
---@field createMany fun(objects: MySQLCreate[])
---@field delete fun(object: MySQLDelete)
---@field deleteMany fun(objects: MySQLDelete[])
---@field findFirst fun(object: MySQLFind)
---@field findMany fun(object: MySQLFind)
---@field findUnique fun(object: MySQLFind)
---@field update fun(object: MySQLUpdate)
---@field updateMany fun(objects: MySQLUpdate[])

Database = {
    ---@type TableMeta credit_cards
    ---@diagnostic disable-next-line: missing-fields
    credit_cards = {} -- Placeholder for credit_cards table
}