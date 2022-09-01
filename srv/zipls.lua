local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

-- @see https://redbean.dev/
-- @see http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
local sqlite3 = require("lsqlite3")

-- TODO: this is very vulnerable to relative path transversal
-- @see https://man.archlinux.org/man/sys_stat.h.0p
-- S_IROTH
local zipfile = GetParam("zipfile")
if string.find(zipfile, "%.%.") or string.find(zipfile, "/%.") or assert(
	unix.stat(zipfile)
):mode() & 04 ~= 04 then
	SetStatus(400)
	SetHeader("Content-Type", "text/plain; charset=utf-8")
	Write("unexpected input")
end

local db = sqlite3.open(database, sqlite3.SQLITE_OPEN_READONLY)

-- @see https://www.sqlite.org/zipfile.html
local stmt =
	db:prepare(
		"SELECT name, mode, mtime, sz, method FROM zipfile(:zipfile) WHERE (mode = 0 or mode & 04 = 04) ORDER BY name"
	)
stmt:bind_names{ zipfile = zipfile }
SetHeader("Content-Type", "text/html; charset=utf-8")

Write(
	"<table><thead><tr><th>name</th><th>mode</th><th>modified</th><th>size</th><th>method</th></tr></thead><tbody>\r\n"
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
	Write("</td><td>")
	Write(EscapeHtml(row.method))
	Write("</td></tr>\r\n")
end
stmt:finalize()
Write("</tbody>\r\n</table>")