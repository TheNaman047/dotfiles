return {
	get_condition = function()
		return package.loaded["ollama"] and require("ollama").status ~= nil
	end,
	-- Define a function to check the status and return the corresponding icon
	get_status_icon = function()
		local status = require("ollama").status()

		if status == "IDLE" then
			return "󱉌"
		elseif status == "WORKING" then
			return "󱉋"
		end
	end,
}
