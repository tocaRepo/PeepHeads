local CrisisDB = {}


-- In-memory storage
local memory_storage = {}
local data_path=""




-- Decode JSON data from a buffer
local function decode_json(buffer_param)
	local data_str = buffer.get_bytes(buffer_param, "data")
	local success, json_data = pcall(json.decode, data_str)

	if not success then
		print("Error decoding JSON: " .. json_data) -- json_data contains the error message
		return nil
	end

	return json_data
end

function CrisisDB.init(path)
	data_path=path
	print("data_path "..data_path.." set")
end

-- Load data from a file or buffer
function CrisisDB.load_data(table)
	local filename = data_path .. table
	local data = sys.load_resource(filename)

	if data then
		local json_data = json.decode(data)
		
		memory_storage[table] = json_data -- Store in memory
		return json_data
	else
		print(error)
	end
	
end



-- Get data, loading it if not already in memory
function CrisisDB.get_data(table)
	if memory_storage[table] then
		return memory_storage[table]
	else
		return CrisisDB.load_data(table)
	end
end

-- Fetch N random elements from the rows
function CrisisDB.fetch_random_elements(tbl, n)
	local data = CrisisDB.get_data(tbl)
	if not data or not data.rows then
		print("No data available to fetch random elements.")
		return {}
	end

	local rows = data.rows
	local count = #rows
	n = math.min(n, count) -- Limit N to the available number of rows

	local selected_indices = {}
	local random_elements = {}

	-- Select unique random indices
	while #random_elements < n do
		local rand_index = math.random(1, count) -- 1-based index
		if not selected_indices[rand_index] then
			selected_indices[rand_index] = true
			table.insert(random_elements, rows[rand_index])
		end
	end

	-- Wrap the random elements in the structure with 'rows' key
	return { rows = random_elements }
end


-- Flush memory
function CrisisDB.flush_memory()
	memory_storage = {}
end

return CrisisDB
