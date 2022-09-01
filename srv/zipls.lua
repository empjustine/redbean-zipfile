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
if array_index_of(arg, zipfile) == nil then
	return ServeError(403, "unauthorized zipfile")
end
local sqlite3 = require("lsqlite3")
local db = sqlite3.open_memory()
local stmt =
	db:prepare(
		"SELECT name, mode, mtime, sz FROM zipfile(:zipfile) WHERE (mode = 0 or mode & 04 = 04) ORDER BY name"
	)
stmt:bind_names{ zipfile = zipfile }
SetHeader("Content-Type", "text/html; charset=utf-8")
Write(
	"<table><thead><tr><th>name</th><th>mode</th><th>modified</th><th>size</th></tr></thead><tbody>\r\n"
)
for row in stmt:nrows() do
	Write("<tr><td>")
	if row.sz > 0 then
		Write('<a href="/zipcat.lua?zipfile=')
		Write(EscapeHtml(EscapeSegment(zipfile)))
		Write("&name=")
		Write(EscapeHtml(row.name))
		Write('">')
		if row.sz < 10000000 and (ends_with(row.name, ".jpg") or ends_with(
			row.name,
			".jpeg"
		)) then
			Write('<img width="64" height="64" src="/zipcat.lua?zipfile=')
			Write(EscapeHtml(EscapeSegment(zipfile)))
			Write("&name=")
			Write(EscapeHtml(row.name))
			Write('" loading="lazy">')
		end
	end
	Write(EscapeHtml(row.name))
	if row.sz > 0 then
		Write("</a>")
	end
	Write("</td><td>")
	Write(oct(row.mode))
	Write("</td><td>")
	Write(FormatHttpDateTime(row.mtime))
	Write("</td><td>")
	Write(row.sz)
	Write("</td></tr>\r\n")
end
stmt:finalize()
Write("</tbody>\r\n</table>")