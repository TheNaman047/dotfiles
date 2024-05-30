require("gen").prompts = {
	["Elaborate_Text"] = {
		prompt = "Elaborate the following text:\n$text",
		replace = true,
	},
	["Fix_Code"] = {
		prompt = "Fix the following code. Only ouput the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
		replace = true,
		extract = "```$filetype\n(.-)```",
	},
	["Generate_Code"] = {
		prompt = "Write a $filetype code snippet to perform the following task:\n$input",
		replace = false,
	},
	["Complete_Function"] = {
		prompt = "Complete the given $filetype function:\n$text",
		replace = true,
		extract = "```$filetype\n(.-)```",
	},
	["Suggest_Changes"] = {
		prompt = "Suggest possible changes to improve the given $filetype code:\n$text",
		replace = false,
		extract = "```$filetype\n(.-)\n```",
	},
	["Design_Algorithm"] = {
		prompt = "Design an algorithm to solve the following problem:\n$text",
		replace = false,
	},
	["Generate_Test_Cases"] = {
		prompt = "Write test cases for the given $filetype function:\n$text",
		replace = false,
		extract = "```$filetype\n(.-)\n```",
	},
	["Refactor_Code"] = {
		prompt = "Refactor the given $filetype code to improve readability and maintainability:\n$text",
		replace = true,
		extract = "```$filetype\n(.-)\n```",
	},
	["Explain_Concept"] = {
		prompt = "Explain the concept of $text in $filetype programming:\n$input",
		replace = false,
	},
	["Debug_Code"] = {
		prompt = "Identify and fix any bugs in the following $filetype code:\n$text",
		replace = true,
		extract = "```$filetype\n(.-)\n```",
	},
	["Optimize_Code"] = {
		prompt = "Optimize the given $filetype code to improve performance:\n$text",
		replace = true,
		extract = "```$filetype\n(.-)\n```",
	},
}
