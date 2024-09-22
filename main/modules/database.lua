local sqlite3 = require("libsqlite.sqlite3")

local M = {}

local db

-- Function to open the database with a passphrase
function M.open_db(db_path, passphrase)
	db = sqlite3.open(db_path)

	if not db then
		print("Failed to open database")
		return nil
	end

	return db
end

-- Function to print a table
function M.print_table(t)
	if type(t) ~= "table" then
		print("Provided value is not a table.")
		return
	end

	for key, value in pairs(t) do
		if type(value) == "table" then
			print(key .. ": ")
			M.print_table(value)  -- Recursive call for nested tables
		else
			print(key .. ": " .. tostring(value))  -- Use tostring to handle nil values
		end
	end
end

-- Function to execute a SELECT query and return results
function M.get_words(query)
	if not db then
		print("Database not opened")
		return nil
	end

	print("Executing query: " .. query)  -- Log the query
	local results = {}

	for row in db:irows(query) do
		
		--M.print_table(row)
		table.insert(results, {
			id = row[1] or nil,     -- Use "N/A" for nil values
			word = row[2] or nil,
			type = row[3] or nil
		})
	end

	--print("Query results:")
	--M.print_table(results)  -- Print the results table
	return results
end

-- Function to execute a non-select query (INSERT, UPDATE, DELETE)
function M.execute_non_select(query)
	if not db then
		print("Database not opened")
		return nil
	end

	local result = db:exec(query)
	if result ~= sqlite3.OK then
		print("Error executing query: " .. result)
	end

	return result
end

-- Function to close the database
function M.close_db()
	if db then
		db:close()
		db = nil
	end
end

return M
