local sqlite3 = require("lsqlite3")

local function array_index_of(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return index
		end
	end
end

if array_index_of(arg, "serve") == nil then
	return ServeError(
		403,
		"not setup for datazip, start redbean.com with serve parameter"
	)
end

local database = GetParam("database")
if array_index_of(arg, database) == nil then
	return ServeError(403, "unauthorized database")
end
local db = sqlite3.open(database, sqlite3.SQLITE_OPEN_READONLY)

if array_index_of(arg, "--cors") then
	SetHeader("Access-Control-Allow-Origin", "*")
	SetHeader("Access-Control-Allow-Headers", "Authorization")
	SetHeader("Access-Control-Expose-Headers", "Link")
end

local start_time = GetTime()

local sql = assert(GetParam("sql"))
local stmt = db:prepare(sql)
stmt:bind_names(GetParams())

local rows = {}
local columns = stmt:get_names()

for row in stmt:rows() do
	local this_row = { [0] = false }
	for i, value in ipairs(row) do
		table.insert(this_row, value)
	end
	table.insert(rows, this_row)
end

stmt:finalize()

local end_time = GetTime()

SetHeader("Content-Type", "application/json")
Write(
	EncodeJson({
		ok = true,
		database = database,
		query_name = nil,
		rows = rows,
		truncated = false,
		columns = columns,
		error = nil,
		private = false,
		allow_execute_sql = true,
		query_ms = ((end_time - start_time) * 1000),
	})
)