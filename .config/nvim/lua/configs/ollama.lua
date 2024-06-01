local function get_condition()
  return package.loaded["ollama"] and require("ollama").status ~= nil
end

-- Define a function to check the status and return the corresponding icon
local function get_status_icon()
  local status = require("ollama").status()

  if status == "IDLE" then
    return "OLLAMA IDLE"
  elseif status == "WORKING" then
    return "OLLAMA BUSY"
  end
end

return { get_condition, get_status_icon }
