-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
sqlite3 = require("lsqlite3")
db = sqlite3.open_memory()

-- TODO: declare in .init.lua instead
local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

-- TODO: declare in .init.lua instead
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

-- TODO: this is very vulnerable to relative path transversal
zipfile = GetParam("zipfile")
if string.find(zipfile, "%.%.") then
	SetStatus(400)
	SetHeader("Content-Type", "text/plain; charset=utf-8")
	Write("unexpected input")
end

if string.sub(
	-- in current dirname
	path.basename(zipfile),
	1,
	1
) == "." then
	return Route("404", "404.html")
end

-- @see https://man.archlinux.org/man/sys_stat.h.0p
-- S_IROTH
if assert(unix.stat(zipfile)):mode() & 04 ~= 04 then
	return Route("404", "404.html")
end

name = GetParam("name")
-- @see https://www.sqlite.org/zipfile.html
stmt = db:prepare("SELECT data FROM zipfile(:zipfile) WHERE name = :name")
stmt:bind_names{
	zipfile = zipfile,
	name = name,
}
SetHeader("Content-Type", naive_mime_by_extension(name))
for row in stmt:nrows() do
	Write(row.data)
end
stmt:finalize()