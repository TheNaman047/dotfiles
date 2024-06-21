return {
	prompts = {
		Elaborate_Text = {
			prompt = "Elaborate the following sel:\n$sel",
			action = "display",
		},
		Fix_Code = {
			prompt = "Fix the following code. Only ouput the result in format ```$ftype\n...\n```:\n```$ftype\n$sel\n```",
			action = "extract",
			extract = "```$ftype\n(.-)```",
		},
		Generate_Code = {
			prompt = "Write a $ftype code snippet to perform the following task:\n$input",
			action = "display",
		},
		Complete_Function = {
			prompt = "Complete the given $ftype function:\n$sel",
			action = "extract",
			extract = "```$ftype\n(.-)```",
		},
		Suggest_Changes = {
			prompt = "Suggest possible changes to improve the given $ftype code:\n$sel",
			action = "extract",
			extract = "```$ftype\n(.-)\n```",
		},
		Design_Algorithm = {
			prompt = "Design an algorithm to solve the following problem:\n$sel",
			action = "display",
		},
		Generate_Test_Cases = {
			prompt = "Write test cases for the given $ftype function:\n$sel",
			action = "insert",
			extract = "```$ftype\n(.-)\n```",
		},
		Refactor_Code = {
			prompt = "Refactor the given $ftype code to improve readability and maintainability:\n$sel",
			action = "extract",
			extract = "```$ftype\n(.-)\n```",
		},
		Explain_Concept = {
			prompt = "Explain the concept of $sel in $ftype programming:\n$input",
			action = "display",
		},
		Debug_Code = {
			prompt = "Identify and fix any bugs in the following $ftype code:\n$sel",
			action = "extract",
			extract = "```$ftype\n(.-)\n```",
		},
		Optimize_Code = {
			prompt = "Optimize the given $ftype code to improve performance:\n$sel",
			action = "extract",
			extract = "```$ftype\n(.-)\n```",
		},
	},
}
