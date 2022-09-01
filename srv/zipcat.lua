local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

local function array_index_of(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return index
		end
	end
end

local function naive_mime_by_extension(path)
	if ends_with(path, ".jpg") or ends_with(path, ".jpeg") then
		return "image/jpeg"
	end
	if ends_with(path, ".dashtoc") then
		return "application/json; charset=utf-8"
	end
	if ends_with(path, ".xml") or ends_with(path, ".plist") then
		return "application/xml; charset=utf-8"
	end
	if ends_with(path, ".htm") or ends_with(path, ".html") then
		return "text/html; charset=utf-8"
	end
	if ends_with(path, ".css") then
		return "text/css; charset=utf-8"
	end
	if ends_with(path, ".js") then
		return "text/javascript; charset=utf-8"
	end
	return "text/plain; charset=utf-8"
end

-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
-- @see https://www.sqlite.org/zipfile.html
local zipfile = GetParam("zipfile")
local name = GetParam("name")
if array_index_of(arg, zipfile) == nil then
	return ServeError(403, "unauthorized zipfile")
end
local sqlite3 = require("lsqlite3")
local db = sqlite3.open_memory()
local stmt =
	db:prepare(
		"SELECT data FROM zipfile(:zipfile) WHERE name = :name and (mode & 04 = 04 or (mode = 0 and sz > 0)) LIMIT 1"
	)
stmt:bind_names{
	zipfile = zipfile,
	name = name,
}
for row in stmt:nrows() do
	SetHeader("Content-Type", naive_mime_by_extension(name))
	Write(row.data)
	stmt:finalize()
	return
end
ServeError(404)
stmt:finalize()