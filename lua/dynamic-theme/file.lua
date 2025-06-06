--- @class Theme
--- @field name string the name of the theme
--- @field selected boolean whether this theme is currently selected
--- @field palette DynamicThemePalette|nil the color palette for this theme

--- @class DynamicThemeFile
--- @field path string the path to the configuration JSON file
--- @field exists fun(): boolean check if the dynamic-theme file exists
--- @field read fun(): Theme[]|nil read and parse the dynamic-theme file
--- @field write fun(theme_list: Theme[]): boolean write themes to the theme file
--- @field save fun(): nil save changes from the UI to the theme file
local M = {}

local config_path = vim.fn.stdpath 'config'
M.path = config_path .. '/dynamic-theme.json'

--- check if the theme file exists
--- @return boolean
M.exists = function()
  local f = io.open(M.path, 'r')
  if f then
    io.close(f)
    return true
  else
    return false
  end
end

--- read and parse the theme file
--- @return Theme[]|nil the array of themes or nil if reading failed
M.read = function()
  local file = io.open(M.path, 'r')
  if file then
    local content = file:read '*a'
    file:close()
    if content then
      local status, decoded = pcall(vim.json.decode, content)
      if status and type(decoded) == 'table' then
        return decoded
      end
    end
  else
    vim.notify('Error reading from theme file', vim.log.levels.ERROR)
  end
  return nil
end

--- write themes to the theme file
--- @param theme_list Theme[] the array of themes to write
--- @return boolean whether the write operation succeeded
M.write = function(theme_list)
  local status, encoded = pcall(vim.json.encode, theme_list, { indent = true })
  if status then
    local file = io.open(M.path, 'w')
    if file then
      file:write(encoded)
      file:close()
      return true
    end
  end
  return false
end

--- save changes from the UI to the theme file
M.save = function()
  local window = require 'dynamic-theme.window'
  window.save_changes()
end

return M
