function create_latex_document()
	-- First check if the directory is empty
	local files = vim.fn.glob("*")
	if #files > 0 then
		-- ask the user if they want to clear the directory and create a new project or quit
		local answer = vim.fn.confirm(
			"The directory is not empty. Do you want to clear it and create a new project?",
			"&Yes\n&No",
			2
		)
		if answer == 1 then
			-- clear the directory
			os.execute("rm -rf *")
		else
			-- quit
			return
		end
	end

	-- Get the path to the template directory
	local template_dir = os.getenv("HOME") .. "/.config/nvim/templates"

	-- Function to create a file from the template
	local function create_file_from_template(template_filename, new_filename)
		-- Open the template file for reading
		local template_file = io.open(template_dir .. "/" .. template_filename, "r")
		if not template_file then
			error("Cannot open template file: " .. template_filename)
		end
		-- Read the contents of the template file
		local output_file = io.open(new_filename, "w")
		if not output_file then
			error("Cannot create output file: " .. new_filename)
		end

		output_file:write(template_file:read("*a"))
		template_file:close()
		output_file:close()
		print("" .. new_filename .. " created successfully!")
	end

	-- Create the 'preamble.tex' file from the template
	create_file_from_template("preamble.tex", "preamble.tex")

	-- Create the 'report.tex' file from the template
	create_file_from_template("report.tex", "report.tex")

  create_file_from_template("coverpage.tex", "coverpage.tex")

  create_file_from_template("macros.tex", "macros.tex")

	-- Create the 'bib.bib' file (empty for this example)
	local bib_file = io.open("bib.bib", "w")
	if not bib_file then
		error("Cannot create bib.bib file")
	end
	bib_file:close()

	-- Create the 'Attachments' directory if it does not exist
	if not os.execute("test -d Attachments || mkdir Attachments") == 0 then
		error("Cannot create Attachments directory")
	end

	-- Create the 'bib.bib' file (empty for this example)
	local todo = io.open("todo.md", "w")
	if not todo then
		error("Cannot create todo.md file")
	end
	todo:close()

	-- Create the 'bib.bib' file (empty for this example)
	local outline = io.open("outline.md", "w")
	if not outline then
		error("Cannot create outline.md file")
	end
	outline:close()

	print("Latex document structure created successfully!")
end

vim.api.nvim_create_user_command("CreateLatexProject", create_latex_document, {})
