local function array_index_of(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return index
		end
	end
end

local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

local sqlar = GetParam("sqlar")
if array_index_of(arg, sqlar) == nil then
	return ServeError(403, "unauthorized sqlar")
end

-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
-- @see https://sqlite.org/sqlar
local sqlite3 = require("lsqlite3")
local db = sqlite3.open(sqlar, sqlite3.SQLITE_OPEN_READONLY)
local stmt =
	db:prepare(
		"SELECT name, mode, mtime, sz FROM sqlar WHERE (mode = 0 or mode & 04 = 04) ORDER BY name"
	)
SetHeader("Content-Type", "text/html; charset=utf-8")
Write(
	"<table><thead><tr><th>name</th><th>mode</th><th>modified</th><th>size</th></tr></thead><tbody>\r\n"
)
for row in stmt:nrows() do
	Write("<tr><td>")
	if row.sz > 0 then
		Write('<a href="/sqlarcat.lua?sqlar=')
		Write(EscapeParam(sqlar))
		Write("&name=")
		Write(EscapeParam(row.name))
		Write('">')
		if row.sz < 10000000 and (ends_with(row.name, ".jpg") or ends_with(
			row.name,
			".jpeg"
		)) then
			Write('<img width="64" height="64" src="/sqlarcat.lua?sqlar=')
			Write(EscapeParam(sqlar))
			Write("&name=")
			Write(EscapeParam(row.name))
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