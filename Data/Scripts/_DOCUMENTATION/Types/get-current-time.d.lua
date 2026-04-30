---@meta
---@diagnostic disable: lowercase-global, missing-return, duplicate-set-field, undefined-global, missing-fields

---@class GetCurrentTime
---Returns the game time in frames.
---@field Frame fun():number
---Returns the galactic game time.
---@field Galactic_Time fun():number

---Returns current time in seconds
---@type GetCurrentTime | fun():number
GetCurrentTime = {}